{ name = "ps-trace-demo"
, dependencies =
  [ "arrays"
  , "console"
  , "effect"
  , "exceptions"
  , "foldable-traversable"
  , "integers"
  , "numbers"
  , "maybe"
  , "prelude"
  , "strings"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
