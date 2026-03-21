module Test.Main where

import Prelude

import Effect (Effect)
import Effect.Class.Console (log)
import Test.Anomaly as Anomaly
import Test.Statistics as Statistics
import Test.Tracer as Tracer

main :: Effect Unit
main = do
  log "Running Tracer tests..."
  Tracer.run
  log "Running Statistics tests..."
  Statistics.run
  log "Running Anomaly tests..."
  Anomaly.run
  log "All tests passed."
