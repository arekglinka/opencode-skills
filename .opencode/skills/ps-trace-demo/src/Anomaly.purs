module Anomaly
  ( isCalibrating
  , detectAnomaly
  , handleAnomaly
  , recordSlowInput
  ) where

import Prelude

import Data.Array as Array
import Data.String.Common as String
import Data.String.Pattern (Pattern(..), Replacement(..))
import Effect (Effect)
import SQLiteCompat (Db, getQuery, runQuery)
import Statistics (calculateMean, calculateStdDev, calculateZScore)
import Tracer (getTraceCount, markAnomaly, writeTrace)
import Types (AnomalyResult)

isCalibrating :: Int -> Boolean
isCalibrating count = count < 100

detectAnomaly :: Int -> Number -> Array Number -> AnomalyResult
detectAnomaly currentCount durationMs recentDurations =
  if isCalibrating currentCount then
    { isAnomaly: false, zScore: 0.0, isCalibrating: true }
  else
    let
      mean = calculateMean recentDurations
      stdDev = calculateStdDev recentDurations
      zScore = calculateZScore durationMs mean stdDev
      anomaly = zScore > 3.0
    in
      if stdDev == 0.0 then
        { isAnomaly: false, zScore: 0.0, isCalibrating: false }
      else
        { isAnomaly: anomaly, zScore, isCalibrating: false }

sqlQuote :: String -> String
sqlQuote s =
  "'" <> String.replace (Pattern "'") (Replacement "''") s <> "'"

recordSlowInput :: Db -> Int -> String -> Effect Unit
recordSlowInput db traceId inputJson = do
  let
    sql =
      "INSERT INTO slow_inputs (trace_id, input_json) VALUES ("
        <> show traceId
        <> ", "
        <> sqlQuote inputJson
        <> ")"
  _ <- runQuery db sql []
  pure unit

handleAnomaly :: Db -> String -> Number -> String -> Effect AnomalyResult
handleAnomaly db toolName durationMs inputJson = do
  traceId <- writeTrace db toolName durationMs inputJson
  count <- getTraceCount db toolName
  rows <- getQuery db "SELECT duration_ms FROM traces WHERE tool_name = ? ORDER BY id DESC LIMIT 100" [ toolName ]
  let
    durations = map _.duration_ms rows
    recentDurations = Array.reverse durations
    result = detectAnomaly count durationMs recentDurations
  if result.isAnomaly then do
    recordSlowInput db traceId inputJson
    markAnomaly db traceId
    pure result
  else
    pure result
