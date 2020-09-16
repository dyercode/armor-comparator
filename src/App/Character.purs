module App.Character where

import Prelude
import Data.Maybe (Maybe(..))
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Properties as HP
import App.Model (Character)
import Halogen.HTML.Events as HE

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
  DexModChanged n -> H.modify_ \st -> st { dexMod = n }

data Action
  = DexModChanged Int

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
                , HE.onChange \c -> Just (DexModChanged 5)
                , HP.value (show character.dexMod)
                ]
            , HH.p_ [ HH.text $ "internal value " <> (show character.dexMod) ]
            ]
        , HH.li_
            [ HH.label [ HP.for "fly-class-skill-checkbox" ] [ HH.text "Fly class skill?" ]
            , HH.input
                [ HP.type_ HP.InputCheckbox
                , HP.id_ "fly-class-skill-checkbox"
                ]
            ]
        , HH.li_
            [ HH.label [ HP.for "points-in-fly" ] [ HH.text "Points in fly" ]
            , HH.input
                [ HP.type_ HP.InputNumber
                , HP.id_ "points-in-fly"
                ]
            ]
        ]
    ]
