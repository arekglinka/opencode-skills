module Test.Main where

import Prelude

import Effect (Effect)
import Effect.Class.Console (log)
import Test.Anomaly as Anomaly
import Test.Hasher as Hasher
import Test.QueryTools as QueryTools
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
  log "Running Hasher tests..."
  Hasher.run
  log "Running Query tools tests..."
  QueryTools.run
  log "All tests passed."
