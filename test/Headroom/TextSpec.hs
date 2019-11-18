{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
module Headroom.TextSpec
  ( spec
  )
where

import           Headroom.Text
import           Headroom.Types                 ( NewLine(..) )
import           RIO
import           Test.Hspec

spec :: Spec
spec = do
  describe "detectNewLine" $ do
    it "detects that given text uses CR new line sequence" $ do
      detectNewLine "hello\rworld" `shouldBe` Just CR

    it "detects that given text uses CRLF new line sequence" $ do
      detectNewLine "hello\r\nworld" `shouldBe` Just CRLF

    it "detects that given text uses LF new line sequence" $ do
      detectNewLine "hello\nworld" `shouldBe` Just LF

    it "detects no new line sequence" $ do
      detectNewLine "hello world" `shouldBe` Nothing

