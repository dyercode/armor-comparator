module App.Utils where

import Prelude

asc :: Int
asc = 1

desc :: Int
desc = -1

plusify :: Int -> String
plusify num = if num >= 0
                then "+" <> (show num)
                else show num
