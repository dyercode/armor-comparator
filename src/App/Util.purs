module App.Utils where

import Prelude

plusify :: Int -> String
plusify num = if num >= 0
                then "+" <> (show num)
                else show num
