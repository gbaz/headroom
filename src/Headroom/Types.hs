{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE NoImplicitPrelude #-}
module Headroom.Types
  ( AppConfig(..)
  , FileType(..)
  , NewLine(..)
  )
where

import           Data.Aeson                     ( FromJSON(parseJSON)
                                                , genericParseJSON
                                                )
import           GHC.Generics                   ( Generic )
import           Headroom.Types.Util            ( aesonOptions
                                                , readEnumCI
                                                )
import           RIO
import qualified RIO.HashMap                   as HM
import qualified RIO.Text                      as T
import           Text.Read                      ( readsPrec )

data AppConfig =
    AppConfig { acFoo     :: T.Text
              , acBar     :: T.Text
              , acOptions :: HM.HashMap T.Text T.Text
              } deriving (Eq, Generic, Show)

data FileType = Haskell deriving (Bounded, Enum, Eq, Ord, Show)

data NewLine = CR | CRLF | LF deriving (Eq, Show)

----------------------------  TYPE CLASS INSTANCES  ----------------------------

instance FromJSON AppConfig where
  parseJSON = genericParseJSON aesonOptions

instance Read FileType where
  readsPrec _ = readEnumCI
