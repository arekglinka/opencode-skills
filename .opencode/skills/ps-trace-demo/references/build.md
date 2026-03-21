# Build & Run

Prerequisites, build commands, and how to run tools.

## Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| PureScript compiler | 0.15.x | `npm i -g purescript@0.15.15` |
| Spago | 0.21.x | `npm i -g spago@0.21.0` |
| Bun | 1.x | `curl -fsSL https://bun.sh/install \| bash` |

## Build

```bash
spago build
```

Compiles `.purs` → ES modules in `output/`.

## Test

```bash
bun scripts/test.sh
```

Uses `bun:sqlite` (Bun-specific). Do NOT use `spago test`.

## Run Tools

```bash
bun scripts/hash.js "hello"
bun scripts/sort.js "[3,1,2]"
bun scripts/demo-run.js
```

## Query Tools

```bash
bun scripts/trace-view.js                      # last 50 traces
bun scripts/trace-view.js --tool hash           # filter by tool
bun scripts/trace-view.js --slow-only           # anomalies only
bun scripts/stats.js --tool sort                # mean, stddev, count
bun scripts/slow-inputs.js                      # anomalous inputs
bun scripts/slow-inputs.js --tool hash          # filter by tool
bun scripts/trace-clean.js --older-than 30      # delete old traces
```

Override DB path: `TRACES_DB=/tmp/my.db bun scripts/hash.js "test"`

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `spago test` "unsupported URL scheme" | Use `bun scripts/test.sh` instead |
| `spago build` "unknown package" | Check `packages.dhall` or add override |
| Stale output | Run `spago build` again |
