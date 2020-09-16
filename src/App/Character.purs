module App.Armor where 

import Prelude

import App.Button (render)
import Data.Maybe (Maybe(..))
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Web.DOM (CharacterData)

type Character =
  { name :: String
  , dexMod :: Int
  , flyingClassSkill :: Boolean
  , flyingRanks :: Int
  }

defaultCharacter :: Character
defaultCharacter = 
    {name: "", dexMod: 0, flyingClassSkill: false, flyingRanks: 0}

component ::  forall q i o m. H.Component HH.HTML q i o m
component =
    H.mkComponent
      {
          initialState: \_ -> {character: defaultCharacter}
          , render
          , eval: H.mkEval $ H.defaultEval {}
      }

data Action = DontHaveYet

render :: forall cs m. Character -> H.ComponentHTML Action cs m
render state =
    HH.section_
      [ HH.h2 
      [
          [HH.ul [
              HH.li[
                  HH.label [HH.for_ $ "dexmod"]
                  HH.input [HH.type_ $ HH.number_,  HH.id_ $ "dexmod"]
              ]
          ]]
      ]]


-- handleAction :: forall cs o m. Action → H.HalogenM State Action cs o m Unit
-- handleAction = case _ of
--   Increment ->
    -- H.modify_ \st -> st { count = st.count + 1 }