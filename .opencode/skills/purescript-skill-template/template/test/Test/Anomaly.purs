module Test.Anomaly where

import Prelude

import Data.Array (head, replicate)
import Data.Array as Array
import Data.Foldable (traverse_)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Class.Console (log)
import Effect.Exception (throw)
import SQLiteCompat (closeDb, getQuery)
import Anomaly (detectAnomaly, handleAnomaly, isCalibrating, recordSlowInput)
import Tracer (initDb, writeTrace)

assert :: String -> Boolean -> Effect Unit
assert msg cond =
  if cond then pure unit else throw ("Assertion failed: " <> msg)

seedTool :: forall a. a -> Int -> Array a
seedTool value n = replicate n value

run :: Effect Unit
run = do
  assert "isCalibrating true under 100" (isCalibrating 99)
  assert "isCalibrating false at 100" (not (isCalibrating 100))

  let normal = detectAnomaly 100 12.0 [ 10.0, 11.0, 12.0, 13.0, 14.0 ]
  assert "normal value not anomaly" (not normal.isAnomaly)
  assert "normal not calibrating" (not normal.isCalibrating)

  let outlierInput = seedTool 10.0 100 <> [ 1000.0 ]
  let outlier = detectAnomaly 101 1000.0 outlierInput
  assert "outlier is anomaly" outlier.isAnomaly
  assert "outlier zscore positive" (outlier.zScore > 3.0)

  let calib = detectAnomaly 20 1000.0 [ 10.0, 10.0, 10.0 ]
  assert "calibrating skips anomaly" (not calib.isAnomaly)
  assert "calibrating true" calib.isCalibrating

  let zeroDev = detectAnomaly 120 10.0 [ 5.0, 5.0, 5.0, 5.0 ]
  assert "stddev=0 no anomaly" (not zeroDev.isAnomaly)
  assert "stddev=0 zscore=0" (zeroDev.zScore == 0.0)

  db <- initDb ":memory:"
  traceId <- writeTrace db "manual" 15.0 "{\"manual\":true}"
  recordSlowInput db traceId "{\"manual\":true}"
  slowRows <- getQuery db "SELECT COUNT(*) AS count FROM slow_inputs WHERE trace_id = ?" [ traceId ]
  case head slowRows of
    Just row -> assert "recordSlowInput inserted row" (row.count == 1)
    Nothing -> throw "recordSlowInput inserted row: no rows"

  traverse_ (\_ -> writeTrace db "echo" 10.0 "{}") (Array.range 1 100)
  result <- handleAnomaly db "echo" 1000.0 "{\"payload\":\"slow\"}"
  assert "handleAnomaly flags anomaly" result.isAnomaly
  flaggedRows <- getQuery db "SELECT is_anomaly FROM traces WHERE tool_name = 'echo' ORDER BY id DESC LIMIT 1" []
  case head flaggedRows of
    Just row -> assert "handleAnomaly marks trace" (row.is_anomaly == 1)
    Nothing -> throw "handleAnomaly marks trace: no rows"
  storedRows <- getQuery db "SELECT COUNT(*) AS count FROM slow_inputs" []
  case head storedRows of
    Just row -> assert "handleAnomaly stores slow input" (row.count >= 1)
    Nothing -> throw "handleAnomaly stores slow input: no rows"

  closeDb db
  log "Anomaly tests: PASS"
