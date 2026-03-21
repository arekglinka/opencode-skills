# Build & Run

Prerequisites, build commands, and how to run tools in this skill template.

## Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| PureScript compiler | 0.15.x | `npm i -g purescript@0.15.15` |
| Spago | 0.21.x | `npm i -g spago@0.21.0` |
| Bun | 1.x | `curl -fsSL https://bun.sh/install \| bash` |

The package set in `packages.dhall` is pinned to the `psc-0.15.15` release. If you upgrade the compiler, update the package set URL and SHA accordingly.

## Build

```bash
spago build
```

Compiles all `.purs` files listed in `spago.dhall` sources (`src/**/*.purs`, `test/**/*.purs`) and emits ES modules into `output/`. Each PureScript module maps to a directory under `output/` containing an `index.js` file:

```
output/
  Tracer/index.js
  Anomaly/index.js
  Statistics/index.js
  SQLiteCompat/index.js
  Types/index.js
  Test.Main/index.js
  ...
```

## Test

```bash
bun scripts/test.sh
```

This script runs `spago build` then loads `output/Test.Main/index.js` under the Bun runtime. Do NOT use `spago test` directly. The tests depend on `bun:sqlite` for FFI, which is a Bun-specific URL scheme. Node.js will reject `bun:` imports with an "unsupported URL scheme" error.

## Run a Tool

```bash
bun scripts/echo.js "hello"
bun scripts/delay.js 500
bun scripts/fail-on-input.js "some text" "pattern"
```

Every script has the shebang `#!/usr/bin/env bun` and can be made executable with `chmod +x`.

## Query Tools

```bash
bun scripts/trace-view.js                      # last 50 traces
bun scripts/trace-view.js --tool echo           # traces for a specific tool
bun scripts/trace-view.js --slow-only           # anomaly traces only
bun scripts/stats.js --tool delay               # mean, stddev, count for a tool
bun scripts/slow-inputs.js                      # all recorded slow inputs
bun scripts/slow-inputs.js --tool echo          # slow inputs for a specific tool
bun scripts/trace-clean.js --older-than 30      # delete traces older than 30 days
```

Set the DB path with `TRACES_DB`:

```bash
TRACES_DB=/tmp/my-traces.db bun scripts/echo.js "test"
```

Default is `./traces.db` in the working directory.

## Add a New Dependency

1. Edit `spago.dhall` and add the package name to the `dependencies` list:

```dhall
{ name = "my-skill"
, dependencies =
    [ "arrays"
    , "console"
    , "effect"
    , "new-package"    -- add here
    ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
```

2. Run `spago build`. Spago will download the package and its transitive dependencies into `.spago/`.

If the package is not in the upstream package set, add it in `packages.dhall` using the override syntax shown in that file's comments.

## Add a New Source Module

Place `.purs` files under `src/` and they are automatically picked up by the glob in `spago.dhall`. FFI files (`.js`) must live alongside their PureScript module. For example, `src/MyModule.purs` pairs with `src/MyModule.js`.

## Troubleshooting

### `spago test` fails with "unsupported URL scheme"

The tests use `bun:sqlite`, a Bun-specific import. `spago test` runs tests under Node.js, which does not understand `bun:` schemes. Use `bun scripts/test.sh` instead.

### `spago build` fails with "unknown package"

The package set is pinned to a specific release. Either the package name is misspelled, or it is not included in that release. Check the package set or add it manually in `packages.dhall`.

### Compiled output is stale after changing `.purs` files

Run `spago build` again. The compiler does incremental builds by default, but does not watch for file changes. There is no hot-reload loop.

### DB "already exists" errors

The `openOrInitDb` helper in scripts handles this gracefully. If `initDb` fails because the DB already exists, it falls back to `openDb`. You should never see this error from a script invocation.
