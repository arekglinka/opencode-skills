module Test.Hasher where

import Prelude

import Effect (Effect)
import Effect.Class.Console (log)
import Effect.Exception (throw)
import Hasher (computeHash, HashResult(..))

assert :: String -> Boolean -> Effect Unit
assert msg cond =
  if cond then pure unit else throw ("Assertion failed: " <> msg)

run :: Effect Unit
run = do
  let r1 = computeHash ""
  case r1 of
    HashResult h -> do
      assert "empty string length" (h.inputLength == 0)

  let r2 = computeHash "hello"
  case r2 of
    HashResult h -> do
      assert "hello length" (h.inputLength == 5)
      assert "hello hex non-empty" (h.hashHex /= "")

  let r3 = computeHash "hello"
  let r4 = computeHash "hello"
  case r3, r4 of
    HashResult h3, HashResult h4 -> do
      assert "deterministic hash" (h3.hashValue == h4.hashValue)
      assert "deterministic hex" (h3.hashHex == h4.hashHex)

  let r5 = computeHash "abc"
  let r6 = computeHash "def"
  case r5, r6 of
    HashResult h5, HashResult h6 -> do
      assert "different inputs different hashes" (h5.hashValue /= h6.hashValue)

  let r7 = computeHash "ps-trace-demo"
  case r7 of
    HashResult h -> do
      assert "show instance works" (show r7 == "{ input: " <> show "ps-trace-demo" <> ", length: " <> show 13 <> ", hash: " <> show h.hashValue <> ", hex: " <> h.hashHex <> " }")

  log "Hasher tests: PASS"
