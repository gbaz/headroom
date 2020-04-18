{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}
module Headroom.Configuration
  ( loadConfiguration
  , makeConfiguration
  , makeHeadersConfig
  , parseVariables
  , parseConfiguration
  )
where

import           Data.Monoid                    ( Last(..) )
import qualified Data.Yaml                     as Y
import           Headroom.Types                 ( ApplicationError(..)
                                                , Configuration(..)
                                                , ConfigurationError(..)
                                                , FileType(..)
                                                , HeaderConfig(..)
                                                , HeadersConfig(..)
                                                , PartialConfiguration(..)
                                                , PartialHeaderConfig(..)
                                                , PartialHeadersConfig(..)
                                                )
import           RIO
import qualified RIO.ByteString                as B
import qualified RIO.HashMap                   as HM
import qualified RIO.Text                      as T


makeConfiguration :: MonadThrow m => PartialConfiguration -> m Configuration
makeConfiguration PartialConfiguration {..} = do
  cRunMode        <- lastOrError NoRunMode pcRunMode
  cSourcePaths    <- lastOrError NoSourcePaths pcSourcePaths
  cTemplatePaths  <- lastOrError NoTemplatePaths pcTemplatePaths
  cVariables      <- lastOrError NoVariables pcVariables
  cLicenseHeaders <- makeHeadersConfig pcLicenseHeaders
  pure Configuration { .. }

makeHeadersConfig :: MonadThrow m => PartialHeadersConfig -> m HeadersConfig
makeHeadersConfig PartialHeadersConfig {..} = do
  hscCss     <- makeHeaderConfig CSS phscCss
  hscHaskell <- makeHeaderConfig Haskell phscHaskell
  hscHtml    <- makeHeaderConfig HTML phscHtml
  hscJava    <- makeHeaderConfig Java phscJava
  hscJs      <- makeHeaderConfig JS phscJs
  hscRust    <- makeHeaderConfig Rust phscRust
  hscScala   <- makeHeaderConfig Scala phscScala
  pure HeadersConfig { .. }

makeHeaderConfig :: MonadThrow m
                 => FileType
                 -> PartialHeaderConfig
                 -> m HeaderConfig
makeHeaderConfig fileType PartialHeaderConfig {..} = do
  hcFileExtensions <- lastOrError (NoFileExtensions fileType) phcFileExtensions
  hcMarginAfter    <- lastOrError (NoMarginAfter fileType) phcMarginAfter
  hcMarginBefore   <- lastOrError (NoMarginBefore fileType) phcMarginBefore
  hcPutAfter       <- lastOrError (NoPutAfter fileType) phcPutAfter
  hcPutBefore      <- lastOrError (NoPutBefore fileType) phcPutBefore
  hcHeaderSyntax   <- lastOrError (NoHeaderSyntax fileType) phcHeaderSyntax
  pure HeaderConfig { .. }

lastOrError :: MonadThrow m => ConfigurationError -> Last a -> m a
lastOrError err (Last x) = maybe (throwM $ ConfigurationError err) pure x

-- | Loads and parses application configuration from given file.
loadConfiguration :: MonadIO m
                  => FilePath               -- ^ path to configuration file
                  -> m PartialConfiguration -- ^ parsed configuration
loadConfiguration path = liftIO $ B.readFile path >>= parseConfiguration

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
    [key, value] -> pure (key, value)
    _            -> throwM $ ConfigurationError (InvalidVariable input)

-- | Parses application configuration from given raw input.
parseConfiguration :: MonadThrow m
                   => B.ByteString           -- ^ raw input to parse
                   -> m PartialConfiguration -- ^ parsed application configuration
parseConfiguration = Y.decodeThrow