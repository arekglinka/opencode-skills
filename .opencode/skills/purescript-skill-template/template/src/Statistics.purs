module Statistics
  ( calculateMean
  , calculateStdDev
  , calculateZScore
  , clampWindow
  , updateRollingWindow
  , getWindow
  , getToolStats
  ) where

import Prelude

import Data.Array as Array
import Data.Foldable (sum)
import Data.Int as Int
import Data.Number (sqrt)
import Types (ToolStats)

calculateMean :: Array Number -> Number
calculateMean xs =
  let n = Array.length xs
  in if n == 0 then 0.0 else sum xs / Int.toNumber n

calculateStdDev :: Array Number -> Number
calculateStdDev xs =
  let
    n = Array.length xs
  in
    if n <= 1 then
      0.0
    else
      let
        mean = calculateMean xs
        variance = sum (map (\x -> (x - mean) * (x - mean)) xs) / Int.toNumber n
      in
        sqrt variance

calculateZScore :: Number -> Number -> Number -> Number
calculateZScore value mean stdDev =
  if stdDev == 0.0 then 0.0 else (value - mean) / stdDev

clampWindow :: Int -> Array Number -> Array Number
clampWindow n xs =
  if n <= 0 then [] else Array.takeEnd n xs

updateRollingWindow :: Int -> Number -> Array Number -> Array Number
updateRollingWindow windowSize value xs =
  clampWindow windowSize (xs <> [ value ])

getWindow :: Int -> Array Number -> Array Number
getWindow = clampWindow

getToolStats :: String -> Array Number -> ToolStats
getToolStats toolName durations =
  { toolName
  , mean: calculateMean durations
  , stdDev: calculateStdDev durations
  , count: Array.length durations
  }
