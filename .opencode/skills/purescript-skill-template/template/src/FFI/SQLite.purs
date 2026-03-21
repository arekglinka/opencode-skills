module FFI.SQLite
  ( Db
  , openDb
  , runQuery
  , getQuery
  , closeDb
  ) where

import Prelude
import Effect (Effect)

foreign import data Db :: Type

foreign import openDb :: String -> Effect Db

foreign import runQuery :: forall a. Db -> String -> Array a -> Effect Boolean

foreign import getQuery :: forall a b. Db -> String -> Array a -> Effect (Array b)

foreign import closeDb :: Db -> Effect Unit
