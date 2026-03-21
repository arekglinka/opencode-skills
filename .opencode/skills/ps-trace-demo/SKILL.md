---
name: ps-trace-demo
description: Demonstrates PureScript skill template features — tracing, anomaly detection, and SQLite storage. Use to learn the traced-tool pattern or as a working reference.
license: MIT
compatibility: opencode
---

Showcase skill for the PureScript skill template. Each tool is traced: invocations are recorded, timed, and checked for anomalies via z-score analysis. All data persists in SQLite.

## Commands

| Command | Description |
|---------|-------------|
| `bun scripts/hash.js "text"` | SHA-256 hash of input |
| `bun scripts/sort.js "[3,1,2]"` | Sort a JSON array of numbers |
| `bun scripts/demo-run.js` | Orchestrated demo: calibration + anomaly trigger |
| `bun scripts/trace-view.js` | Last 50 traces (see refs for filters) |
| `bun scripts/stats.js --tool hash` | Mean, stddev, count for a tool |
| `bun scripts/slow-inputs.js` | All anomalous inputs recorded |
| `bun scripts/trace-clean.js --older-than 30` | Delete traces older than N days |

## What This Demonstrates

| Feature | Tool |
|---------|------|
| Tracing pipeline | All tools — every call writes to `traces` table |
| Anomaly detection (z-score) | `demo-run` — seeds 100 normal calls then sends an outlier |
| Slow input capture | `slow-inputs.js` — queries `slow_inputs` table |
| SQLite storage | `traces.db` — auto-created on first run |
| PureScript modules | `src/` — typed tracing, statistics, FFI |
| Query tools | `trace-view`, `stats`, `slow-inputs`, `trace-clean` |

## Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| PureScript | 0.15.x | `npm i -g purescript@0.15.15` |
| Spago | 0.21.x | `npm i -g spago@0.21.0` |
| Bun | 1.x | `curl -fsSL https://bun.sh/install \| bash` |

## Build & Test

```bash
spago build              # compile PureScript
bun scripts/test.sh      # run test suite
bun scripts/demo-run.js  # see it in action
```

## Refs

- [build](references/build.md) — toolchain, adding deps, troubleshooting
- [tracing patterns](references/tracing-patterns.md) — pipeline, anomaly params, DB schema
- [schema](references/schema.sql) — SQLite DDL
