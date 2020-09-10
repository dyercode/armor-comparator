module Test.Main where

import Prelude

import Effect (Effect)
import Effect.Aff (launchAff_)
import Test.Spec (describe, it)
import Test.Spec.Assertions (shouldEqual)
import Test.Spec.Reporter.Console (consoleReporter)
import Test.Spec.Runner (runSpec)
import App.Utils (plusify)

main :: Effect Unit
main = launchAff_ $ runSpec [consoleReporter] do
 describe "plusify is a helper function" do
   it "Prepends the plus sign to a positive number" do
     plusify (1) `shouldEqual` "+1"
   it "Prepends the plus sign to zero" do
     plusify (0) `shouldEqual` "+0"
   it "Does not change negative" do
     plusify (-1) `shouldEqual` "-1"