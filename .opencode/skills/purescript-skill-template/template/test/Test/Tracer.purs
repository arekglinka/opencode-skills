module Test.Tracer where

import Prelude

import Data.Array (length)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Class.Console (log)
import Effect.Exception (throw)
import SQLiteCompat (closeDb, getQuery, runQuery)
import Tracer (deleteOldTraces, getTraceCount, initDb, readTrace, readTracesByTool, writeTrace)

assert :: String -> Boolean -> Effect Unit
assert msg cond =
  if cond then pure unit else throw ("Assertion failed: " <> msg)

run :: Effect Unit
run = do
  db <- initDb ":memory:"

  metaRows <- getQuery db "SELECT value FROM _schema_meta WHERE key = 'version'" []
  assert "initDb created _schema_meta" (length metaRows == 1)

  id1 <- writeTrace db "tool-a" 10.0 "{\"a\":1}"
  assert "writeTrace returns positive id" (id1 > 0)

  mTrace <- readTrace db id1
  case mTrace of
    Nothing -> throw "readTrace returned Nothing"
    Just trace -> do
      assert "readTrace toolName" (trace.toolName == "tool-a")
      assert "readTrace duration" (trace.durationMs == 10.0)

  mMissing <- readTrace db 999999
  assert "readTrace returns Nothing when missing" (case mMissing of
    Nothing -> true
    _ -> false)

  _ <- writeTrace db "tool-a" 20.0 "{}"
  _ <- writeTrace db "tool-b" 30.0 "{}"
  toolATraces <- readTracesByTool db "tool-a"
  assert "readTracesByTool filters tool" (length toolATraces == 2)

  countA <- getTraceCount db "tool-a"
  countB <- getTraceCount db "tool-b"
  assert "getTraceCount for tool-a" (countA == 2)
  assert "getTraceCount for tool-b" (countB == 1)

  idOld <- writeTrace db "tool-old" 40.0 "{}"
  _ <- runQuery db "UPDATE traces SET timestamp = datetime('now', '-10 days') WHERE id = ?" [ idOld ]
  deleted <- deleteOldTraces db 5
  assert "deleteOldTraces deletes old records" (deleted >= 1)

  oldTrace <- readTrace db idOld
  assert "deleted trace no longer exists" (case oldTrace of
    Nothing -> true
    _ -> false)

  closeDb db
  log "Tracer tests: PASS"
