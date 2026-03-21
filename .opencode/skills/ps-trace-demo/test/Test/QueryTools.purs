module Test.QueryTools where

import Prelude

import Data.Array (head, length)
import Data.Maybe (Maybe(..))
import Data.Number (abs)
import Effect (Effect)
import Effect.Class.Console (log)
import Effect.Exception (throw)
import Anomaly (recordSlowInput)
import SQLiteCompat (closeDb, getQuery, runQuery)
import Statistics (getToolStats)
import Tracer (deleteOldTraces, initDb, markAnomaly, writeTrace)

assert :: String -> Boolean -> Effect Unit
assert msg cond =
  if cond then pure unit else throw ("Assertion failed: " <> msg)

assertNear :: String -> Number -> Number -> Number -> Effect Unit
assertNear msg expected actual eps =
  assert (msg <> " expected=" <> show expected <> " actual=" <> show actual) (abs (expected - actual) <= eps)

run :: Effect Unit
run = do
  db <- initDb ":memory:"

  _ <- writeTrace db "echo" 10.0 "{\"input\":\"a\"}"
  id2 <- writeTrace db "echo" 20.0 "{\"input\":\"b\"}"
  _ <- writeTrace db "echo" 30.0 "{\"input\":\"c\"}"
  _ <- writeTrace db "delay" 40.0 "{\"ms\":40}"

  markAnomaly db id2
  recordSlowInput db id2 "{\"input\":\"b\"}"

  traceRows <- getQuery db "SELECT id, tool_name, duration_ms, is_anomaly FROM traces WHERE tool_name = ? ORDER BY id DESC LIMIT 2" [ "echo" ]
  assert "trace-view tool filter + limit" (length traceRows == 2)

  slowRows <- getQuery db "SELECT id, tool_name, is_anomaly FROM traces WHERE tool_name = ? AND is_anomaly = 1 ORDER BY id DESC LIMIT 50" [ "echo" ]
  case head slowRows of
    Just row -> assert "trace-view slow-only returns anomaly" (row.id == id2 && row.is_anomaly == 1)
    Nothing -> throw "trace-view slow-only returned no rows"

  joinedRows <- getQuery db "SELECT s.trace_id, t.tool_name, t.duration_ms, s.input_json FROM slow_inputs s JOIN traces t ON t.id = s.trace_id WHERE t.tool_name = ? ORDER BY s.id DESC" [ "echo" ]
  case head joinedRows of
    Just row -> do
      assert "slow-inputs join trace id" (row.trace_id == id2)
      assert "slow-inputs join tool" (row.tool_name == "echo")
    Nothing -> throw "slow-inputs join returned no rows"

  durationsRows <- getQuery db "SELECT duration_ms FROM traces WHERE tool_name = ? ORDER BY id DESC" [ "echo" ]
  let stats = getToolStats "echo" (map _.duration_ms durationsRows)
  assert "stats count" (stats.count == 3)
  assertNear "stats mean" 20.0 stats.mean 0.0001
  assert "stats stddev positive" (stats.stdDev > 0.0)

  oldId <- writeTrace db "echo" 50.0 "{\"input\":\"old\"}"
  _ <- runQuery db "UPDATE traces SET timestamp = datetime('now', '-400 days') WHERE id = ?" [ oldId ]
  deleted <- deleteOldTraces db 365
  assert "trace-clean deleted old rows" (deleted >= 1)
  checkOld <- getQuery db "SELECT COUNT(*) AS count FROM traces WHERE id = ?" [ oldId ]
  case head checkOld of
    Just row -> assert "trace-clean removed old record" (row.count == 0)
    Nothing -> throw "trace-clean post-check returned no rows"

  closeDb db
  log "Query tools tests: PASS"
