module Hasher
  ( computeHash
  , HashResult(..)
  ) where

import Prelude

import Data.String.CodeUnits as CodeUnits

foreign import nativeHash :: String -> Int
foreign import intToHex :: Int -> String

data HashResult = HashResult
  { input :: String
  , inputLength :: Int
  , hashValue :: Int
  , hashHex :: String
  }

computeHash :: String -> HashResult
computeHash input =
  let
    hashVal = nativeHash input
    len = CodeUnits.length input
  in
    HashResult
      { input
      , inputLength: len
      , hashValue: hashVal
      , hashHex: intToHex hashVal
      }

instance showHashResult :: Show HashResult where
  show (HashResult r) =
    "{ input: " <> show r.input
      <> ", length: " <> show r.inputLength
      <> ", hash: " <> show r.hashValue
      <> ", hex: " <> r.hashHex
      <> " }"
