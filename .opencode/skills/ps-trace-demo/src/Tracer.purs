module Tracer
  ( initDb
  , writeTrace
  , readTrace
  , readTracesByTool
  , getTraceCount
  , deleteOldTraces
  , markAnomaly
  ) where

import Prelude

import Data.Array (head)
import Data.Foldable (traverse_)
import Data.Maybe (Maybe, maybe)
import Data.String.CodeUnits as CodeUnits
import Data.String.Common as String
import Data.String.Pattern (Pattern(..), Replacement(..))
import Effect (Effect)
import SQLiteCompat (Db, getQuery, openDb, runQuery)
import Types (Trace)

type TraceRow =
  { id :: Int
  , tool_name :: String
  , timestamp :: String
  , duration_ms :: Number
  , input_json :: String
  , input_hash :: String
  , is_anomaly :: Int
  }

type CountRow = { count :: Int }
type IdRow = { id :: Int }

foreign import readSchemaFile :: Effect String

toTrace :: TraceRow -> Trace
toTrace row =
  { id: row.id
  , toolName: row.tool_name
  , timestamp: row.timestamp
  , durationMs: row.duration_ms
  , inputJson: row.input_json
  , inputHash: row.input_hash
  , isAnomaly: row.is_anomaly /= 0
  }

mkInputPayload :: String -> { inputJson :: String, inputHash :: String }
mkInputPayload inputJson =
  let
    maxLen = 65536
    n = CodeUnits.length inputJson
  in
    if n > maxLen then
      { inputJson: CodeUnits.take maxLen inputJson
      , inputHash: "truncated:" <> show n <> ":" <> CodeUnits.take 16 inputJson
      }
    else
      { inputJson, inputHash: "" }

sqlQuote :: String -> String
sqlQuote s =
  "'" <> String.replace (Pattern "'") (Replacement "''") s <> "'"

initDb :: String -> Effect Db
initDb path = do
  db <- openDb path
  schema <- readSchemaFile
  let statements = String.split (Pattern ";") schema
  traverse_ (\stmt ->
    let trimmed = String.trim stmt
    in if trimmed == "" then pure true else runQuery db trimmed []
    ) statements
  pure db

writeTrace :: Db -> String -> Number -> String -> Effect Int
writeTrace db toolName durationMs inputJson = do
  let payload = mkInputPayload inputJson
  let sql =
        "INSERT INTO traces (tool_name, duration_ms, input_json, input_hash, is_anomaly) VALUES ("
          <> sqlQuote toolName
          <> ", "
          <> show durationMs
          <> ", "
          <> sqlQuote payload.inputJson
          <> ", "
          <> sqlQuote payload.inputHash
          <> ", 0)"
  _ <- runQuery db sql []
  ids <- getQuery db "SELECT id FROM traces ORDER BY id DESC LIMIT 1" [] :: Effect (Array IdRow)
  pure $ maybe 0 _.id (head ids)

readTrace :: Db -> Int -> Effect (Maybe Trace)
readTrace db traceId = do
  rows <- getQuery db "SELECT id, tool_name, timestamp, duration_ms, COALESCE(input_json, '') AS input_json, COALESCE(input_hash, '') AS input_hash, is_anomaly FROM traces WHERE id = ?" [ traceId ] :: Effect (Array TraceRow)
  pure $ map toTrace (head rows)

readTracesByTool :: Db -> String -> Effect (Array Trace)
readTracesByTool db toolName = do
  rows <- getQuery db "SELECT id, tool_name, timestamp, duration_ms, COALESCE(input_json, '') AS input_json, COALESCE(input_hash, '') AS input_hash, is_anomaly FROM traces WHERE tool_name = ? ORDER BY id DESC" [ toolName ] :: Effect (Array TraceRow)
  pure $ map toTrace rows

getTraceCount :: Db -> String -> Effect Int
getTraceCount db toolName = do
  rows <- getQuery db "SELECT COUNT(*) AS count FROM traces WHERE tool_name = ?" [ toolName ] :: Effect (Array CountRow)
  pure $ maybe 0 _.count (head rows)

deleteOldTraces :: Db -> Int -> Effect Int
deleteOldTraces db days = do
  let daysStr = "-" <> show days <> " days"
  counts <- getQuery db "SELECT COUNT(*) AS count FROM traces WHERE timestamp < datetime('now', ?)" [ daysStr ] :: Effect (Array CountRow)
  let deleted = maybe 0 _.count (head counts)
  _ <- runQuery db "DELETE FROM traces WHERE timestamp < datetime('now', ?)" [ daysStr ]
  pure deleted

markAnomaly :: Db -> Int -> Effect Unit
markAnomaly db traceId = do
  _ <- runQuery db "UPDATE traces SET is_anomaly = 1 WHERE id = ?" [ traceId ]
  pure unit
