module Test.Main where

import Prelude

import Effect (Effect)
import Effect.Aff (launchAff_)
import Test.Spec (describe, it)
import Test.Spec.Assertions (shouldEqual)
import Test.Spec.Reporter.Console (consoleReporter)
import Test.Spec.Runner (runSpec)
import App.Utils (plusify)
import App.Armor (totalMaxDex)
import Test.Spec.QuickCheck (quickCheck)
import Test.QuickCheck ((===), (/==))

main :: Effect Unit
main = launchAff_ $ runSpec [consoleReporter] do
  describe "plusify is a helper function" do
    it "Prepends the plus sign to a positive number" do
      plusify (1) `shouldEqual` "+1"
    it "Prepends the plus sign to zero" do
      plusify (0) `shouldEqual` "+0"
    it "Does not change negative" do
      plusify (-1) `shouldEqual` "-1"
  describe "totalMaxDex" do
    let armor = \dex mithral -> { name : "fp", armor : 0, maxDex: dex, cost: 0, mithral: mithral, comfortable: false, checkPenalty : 0 }
    it "non-mithral is raw value adds 2" do
      quickCheck \n -> totalMaxDex (armor n false)  === n
    it "mithral adds 2" do
      quickCheck \n -> totalMaxDex (armor n true)  === n + 2