{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
module Headroom.UI.ProgressSpec
  ( spec
  )
where

import           Headroom.UI.Progress
import           RIO
import           Test.Hspec

spec :: Spec
spec = do
  describe "zipWithProgress" $ do
    it "zips progress for given collection" $ do
      let col      = ["a", "b"] :: [Text]
          actual   = zipWithProgress col
          expected = [(Progress 1 2, "a"), (Progress 2 2, "b")]
      actual `shouldBe` expected

  describe "show" $ do
    it "displays correct output for Progress data type" $ do
      textDisplay (Progress 1 1) `shouldBe` "[1 of 1]"
      textDisplay (Progress 10 250) `shouldBe` "[ 10 of 250]"
