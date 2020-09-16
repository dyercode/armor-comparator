module App.Character where

import Prelude
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Properties as HP

type Character
  = { name :: String
    , dexMod :: Int
    , flyingClassSkill :: Boolean
    , flyingRanks :: Int
    }

defaultCharacter :: Character
defaultCharacter =
  { name: ""
  , dexMod: 0
  , flyingClassSkill: false
  , flyingRanks: 0
  }

component :: forall q i o m. H.Component HH.HTML q i o m
component =
  H.mkComponent
    { initialState: \_ -> defaultCharacter
    , render
    , eval: H.mkEval $ H.defaultEval { handleAction = handleAction }
    }

handleAction :: forall cs o m. Action → H.HalogenM Character Action cs o m Unit
handleAction = case _ of
  DontHaveYet -> H.modify_ \st -> st { dexMod = st.dexMod + 1 }

data Action
  = DontHaveYet

render :: forall cs m. Character -> H.ComponentHTML Action cs m
render character =
  HH.section_
    [ HH.h2_ [ HH.text "Player Info" ]
    , HH.ul_
        [ HH.li_
            [ HH.label [ HP.for "dexmod" ] [ HH.text "Dex Modifier" ]
            , HH.input
                [ HP.type_ HP.InputNumber
                , HP.id_ "dexmod"
                ]
            ]
        ]
    ]

-- HH.section_
-- [ HH.h2
-- [ HH.ul
-- [ HH.li
-- [ HH.label [ HP.for "dexmod" ] ]
-- , HH.li
-- [ 
-- HH.input [ HP.type_ HP.InputNumber]  
-- ]
-- ]
-- ]
-- ]
-- handleAction :: forall cs o m. Action → H.HalogenM State Action cs o m Unit
-- handleAction = case _ of
--   Increment ->
-- H.modify_ \st -> st { count = st.count + 1 }
