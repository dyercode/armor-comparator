module Mithral exposing (Mithral(..), fromBool)


type Mithral
    = Mithral
    | NonMithral


fromBool : Bool -> Mithral
fromBool b =
    if b then
        Mithral

    else
        NonMithral
