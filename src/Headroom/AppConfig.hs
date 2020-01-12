{-|
Module      : Headroom.AppConfig
Description : Application configuration
Copyright   : (c) 2019-2020 Vaclav Svejcar
License     : BSD-3
Maintainer  : vaclav.svejcar@gmail.com
Stability   : experimental
Portability : POSIX

This module adds support for loading and parsing application configuration.
Such configuration can be loaded either from /YAML/ config file, or from command
line arguments. Provided 'Semigroup' and 'Monoid' instances allows to merge
multiple loaded configurations into one.
-}
{-# LANGUAGE DeriveGeneric     #-}
{-# LANGUAGE NoImplicitPrelude #-}
module Headroom.AppConfig
  ( AppConfig(..)
  , loadAppConfig
  , makePathsRelativeTo
  , parseAppConfig
  , parseVariables
  , validateAppConfig
  )
where

import           Control.Lens
import           Data.Aeson                     ( FromJSON(parseJSON)
                                                , genericParseJSON
                                                )
import           Data.Functor                   ( (<$) )
import           Data.Validation
import qualified Data.Yaml                     as Y
import           Headroom.Types                 ( AppConfigError(..)
                                                , HeadroomError(..)
                                                , RunMode(..)
                                                )
import           Headroom.Types.Utils           ( customOptions )
import           RIO
import qualified RIO.ByteString                as B
import           RIO.FilePath                   ( takeDirectory
                                                , (</>)
                                                )
import           RIO.HashMap                    ( HashMap )
import qualified RIO.HashMap                   as HM
import           RIO.Text                       ( Text )
import qualified RIO.Text                      as T

-- | Application configuration, loaded either from configuration file or command
-- line options.
data AppConfig = AppConfig
  { acConfigVersion :: Int               -- ^ version of configuration
  , acRunMode       :: RunMode           -- ^ selected mode of /Run/ command
  , acSourcePaths   :: [FilePath]        -- ^ paths to source code files
  , acTemplatePaths :: [FilePath]        -- ^ paths to template files
  , acVariables     :: HashMap Text Text -- ^ variables to replace
  }
  deriving (Eq, Generic, Show)

-- | Support for reading configuration from /YAML/.
instance FromJSON AppConfig where
  parseJSON = genericParseJSON customOptions

instance Semigroup AppConfig where
  x <> y = AppConfig (acConfigVersion x `min` acConfigVersion y)
                     (acRunMode x)
                     (acSourcePaths x <> acSourcePaths y)
                     (acTemplatePaths x <> acTemplatePaths y)
                     (acVariables x <> acVariables y)

instance Monoid AppConfig where
  mempty = AppConfig 1 Add [] [] HM.empty

-- | Loads and parses application configuration from given file.
loadAppConfig :: MonadIO m
              => FilePath    -- ^ path to configuration file
              -> m AppConfig -- ^ parsed configuration
loadAppConfig path = do
  appConfig <- liftIO $ B.readFile path >>= parseAppConfig
  return $ makePathsRelativeTo (takeDirectory path) appConfig

-- | Rewrites all file paths in 'AppConfig' to be relative to given file path.
makePathsRelativeTo :: FilePath  -- ^ file path to use
                    -> AppConfig -- ^ input application configuration
                    -> AppConfig -- ^ result with relativized file paths
makePathsRelativeTo root appConfig = appConfig
  { acSourcePaths   = processPaths . acSourcePaths $ appConfig
  , acTemplatePaths = processPaths . acTemplatePaths $ appConfig
  }
  where processPaths = fmap (root </>)

-- | Parses application configuration from given raw input.
parseAppConfig :: MonadThrow m
               => B.ByteString -- ^ raw input to parse
               -> m AppConfig  -- ^ parsed application configuration
parseAppConfig = Y.decodeThrow

-- | Parses variables from raw input in @key=value@ format.
--
-- >>> parseVariables ["key1=value1"]
-- fromList [("key1","value1")]
parseVariables :: MonadThrow m
               => [Text]                -- ^ list of raw variables
               -> m (HashMap Text Text) -- ^ parsed variables
parseVariables variables = fmap HM.fromList (mapM parse variables)
 where
  parse input = case T.split (== '=') input of
    [key, value] -> return (key, value)
    _            -> throwM $ InvalidPlaceholder input

validateAppConfig :: MonadThrow m => AppConfig -> m AppConfig
validateAppConfig ac@(AppConfig version _ sourcePaths templatePaths _) =
  case checked of
    Success ac'    -> return ac'
    Failure errors -> throwM $ InvalidAppConfig errors
 where
  checked :: Validation [AppConfigError] AppConfig
  checked = ac <$ checkVersion <* checkSourcePaths <* checkTemplatePaths
  checkSourcePaths =
    if null sourcePaths then _Failure # [EmptySourcePaths] else _Success # ac
  checkTemplatePaths = if null templatePaths
    then _Failure # [EmptyTemplatePaths]
    else _Success # ac
  checkVersion = if version /= acConfigVersion mempty
    then _Failure # [InvalidVersion version (acConfigVersion mempty)]
    else _Success # ac
