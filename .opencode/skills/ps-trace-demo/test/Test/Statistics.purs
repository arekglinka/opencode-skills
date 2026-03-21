module Test.Statistics where

import Prelude

import Effect (Effect)
import Effect.Class.Console (log)
import Effect.Exception (throw)
import Data.Number (abs)
import Statistics (calculateMean, calculateStdDev, calculateZScore, clampWindow, getToolStats, updateRollingWindow)

assert :: String -> Boolean -> Effect Unit
assert msg cond =
  if cond then pure unit else throw ("Assertion failed: " <> msg)

assertNear :: String -> Number -> Number -> Number -> Effect Unit
assertNear msg expected actual eps =
  assert (msg <> " expected=" <> show expected <> " actual=" <> show actual) (abs (expected - actual) <= eps)

run :: Effect Unit
run = do
  assertNear "mean [1..5]" 3.0 (calculateMean [ 1.0, 2.0, 3.0, 4.0, 5.0 ]) 0.0001
  assertNear "mean []" 0.0 (calculateMean []) 0.0001
  assertNear "stddev constant" 0.0 (calculateStdDev [ 5.0, 5.0, 5.0 ]) 0.0001
  assert "stddev varied > 0" (calculateStdDev [ 1.0, 2.0, 3.0, 4.0 ] > 0.0)
  assertNear "zscore standard" 2.0 (calculateZScore 5.0 3.0 1.0) 0.0001
  assertNear "zscore stddev 0" 0.0 (calculateZScore 99.0 10.0 0.0) 0.0001
  assert "clampWindow keeps last N" (clampWindow 3 [ 1.0, 2.0, 3.0, 4.0, 5.0 ] == [ 3.0, 4.0, 5.0 ])
  assert "updateRollingWindow appends and clamps" (updateRollingWindow 3 4.0 [ 1.0, 2.0, 3.0 ] == [ 2.0, 3.0, 4.0 ])
  let stats = getToolStats "echo" [ 10.0, 20.0, 30.0 ]
  assert "getToolStats toolName" (stats.toolName == "echo")
  assert "getToolStats count" (stats.count == 3)
  assertNear "getToolStats mean" 20.0 stats.mean 0.0001
  log "Statistics tests: PASS"
