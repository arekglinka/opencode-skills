---
name: purescript-skill-template
description: Generates skills with PureScript tools and built-in execution tracing, anomaly detection, and SQLite storage. Use when creating new skills that need performance monitoring.
license: MIT
compatibility: opencode
---

## Intent

Template for building OpenCode skills with PureScript — typed, traced, and storage-ready out of the box.

## Usage

1. Copy `template/` to new skill directory under `.opencode/skills/<name>/`
2. Edit `spago.dhall` — update `name` and dependencies
3. Write skill logic in `src/`
4. Generate: `spago build && bun scripts/build.sh`

## Structure

```
<skill-name>/
├── SKILL.md              # skill definition
├── spago.dhall           # PureScript project config
├── packages.dhall        # dependency versions
├── src/                  # PureScript source modules
├── scripts/
│   ├── build.sh          # compile & bundle
│   └── test.sh           # run tests
├── template/             # scaffolding source (copy to generate)
└── references/
    ├── build.md          # build & toolchain details
    └── tracing-patterns.md  # tracing & anomaly detection
```

## Commands

| Command | Description |
|---------|-------------|
| `spago build` | Compile PureScript sources |
| `bun scripts/test.sh` | Run test suite |
| `bun scripts/build.sh` | Bundle for execution |

## Built-in Features

| Feature | Purpose |
|---------|---------|
| Execution tracing | Track tool invocations and timing |
| Anomaly detection | Flag unexpected patterns in traces |
| SQLite storage | Persist traces and metrics locally |

## Refs

- [build](references/build.md) — toolchain setup and build config
- [tracing patterns](references/tracing-patterns.md) — tracing, anomalies, storage
