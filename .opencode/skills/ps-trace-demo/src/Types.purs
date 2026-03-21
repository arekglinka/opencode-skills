module Types where

import Prelude

type Trace = {
  id :: Int,
  toolName :: String,
  timestamp :: String,
  durationMs :: Number,
  inputJson :: String,
  inputHash :: String,
  isAnomaly :: Boolean
}

type SlowInput = {
  id :: Int,
  traceId :: Int,
  inputJson :: String,
  createdAt :: String
}

type ToolStats = {
  toolName :: String,
  mean :: Number,
  stdDev :: Number,
  count :: Int
}

type AnomalyResult = {
  isAnomaly :: Boolean,
  zScore :: Number,
  isCalibrating :: Boolean
}

schemaVersion :: Int
schemaVersion = 1
