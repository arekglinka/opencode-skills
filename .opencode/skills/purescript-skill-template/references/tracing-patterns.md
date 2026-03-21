# Tracing Patterns

How tool-call tracing works in this template: defining traced tools, understanding the pipeline, and using query tools.

## Anatomy of a Traced Tool

Every traced tool script follows the same skeleton. Here is `scripts/echo.js` as a reference:

```js
#!/usr/bin/env bun

import * as Tracer from "../output/Tracer/index.js";
import * as Anomaly from "../output/Anomaly/index.js";
import * as SQLiteCompat from "../output/SQLiteCompat/index.js";

const dbPath = process.env.TRACES_DB ?? "./traces.db";
const input = process.argv.slice(2).join(" ");

function openOrInitDb(path) {
  try {
    return Tracer.initDb(path)();
  } catch (err) {
    const msg = String(err?.message ?? err);
    if (msg.includes("already exists")) {
      return SQLiteCompat.openDb(path)();
    }
    throw err;
  }
}

let db;
try {
  db = openOrInitDb(dbPath);
  const started = performance.now();
  // --- YOUR TOOL LOGIC HERE ---
  const output = input;
  // ----------------------------
  const elapsed = performance.now() - started;
  Anomaly.handleAnomaly(db)("echo")(elapsed)(JSON.stringify({ input }))();
  process.stdout.write(`${output}\n`);
} finally {
  if (db) SQLiteCompat.closeDb(db)();
}
```

Key points:

1. Import compiled PureScript modules from `output/`. PureScript FFI functions are curried, so every call chain ends with `()` to invoke the outermost thunk.
2. `openOrInitDb` creates the DB and runs the schema on first use, or just opens it on subsequent calls.
3. Time the tool work with `performance.now()` before and after.
4. Call `Anomaly.handleAnomaly(db)(toolName)(durationMs)(inputJson)()`. This is a single call that writes the trace, checks for anomalies, and records slow inputs if needed.
5. Close the DB in a `finally` block.

### Adding a New Traced Tool

1. Create `scripts/my-tool.js` with the skeleton above.
2. Replace the tool logic section with your actual work.
3. Set the tool name string (`"my-tool"`) in the `handleAnomaly` call.
4. Pass a JSON-serialized input object so traces have useful context.
5. Make it executable: `chmod +x scripts/my-tool.js`.
6. Run it: `bun scripts/my-tool.js arg1 arg2`.

## The Tracing Pipeline

`handleAnomaly` in `Anomaly.purs` orchestrates the full pipeline in one call:

```
handleAnomaly db toolName durationMs inputJson
    |
    v
writeTrace          -- INSERT into traces table
    |
    v
getTraceCount       -- COUNT(*) for this tool
    |
    v
getQuery             -- SELECT last 100 durations for this tool
    |
    v
detectAnomaly       -- z-score check against rolling window
    |
    v
recordSlowInput     -- if anomaly: save full input to slow_inputs
    |
    v
markAnomaly         -- if anomaly: UPDATE traces SET is_anomaly = 1
```

The function returns an `AnomalyResult` record:

```purescript
type AnomalyResult = {
  isAnomaly :: Boolean,
  zScore :: Number,
  isCalibrating :: Boolean
}
```

## Anomaly Detection

Anomaly detection uses a z-score threshold on a rolling window of the 100 most recent durations per tool.

**Parameters:**

| Parameter | Value | Meaning |
|-----------|-------|---------|
| Calibration threshold | 100 traces | First 100 calls are not checked for anomalies |
| Rolling window | 100 durations | Only the most recent 100 durations are used |
| Z-score threshold | 3.0 | Durations exceeding 3 standard deviations from the mean are flagged |
| Zero-stddev guard | skip | If stddev is 0 (all durations identical), no anomaly is flagged |

The calibration period (`count < 100`) ensures the model has enough data before making judgments. During calibration, `handleAnomaly` still writes traces but always returns `isAnomaly: false`.

## Input Handling

Inputs are serialized as JSON and stored in the `traces` table. Large inputs are truncated:

- **Max size**: 64,536 characters (64 KB)
- **Truncation**: If the input exceeds the limit, the first 64,536 characters are stored in `input_json` and a hash is written to `input_hash` in the format `truncated:<original_length>:<first_16_chars>`.
- **Normal inputs**: `input_hash` is an empty string.

When an anomaly is detected, the **full** (untruncated) input is written to the `slow_inputs` table via `recordSlowInput`, so you never lose the data that caused the slowdown.

## Database

The trace database is a single SQLite file:

- **Default location**: `./traces.db` in the skill folder (alongside `local-memory.md`).
- **Override**: Set the `TRACES_DB` environment variable.
- **Schema**: See `references/schema.sql` for the full DDL. Versioned with a `_schema_meta` table.
- **Init**: `Tracer.initDb` reads `references/schema.sql` at runtime and executes each statement. The `readSchemaFile` FFI function resolves the path relative to the compiled output location.

### Schema Overview

Two main tables:

- **traces**: One row per tool invocation. Columns: `id`, `tool_name`, `timestamp`, `duration_ms`, `input_json`, `input_hash`, `is_anomaly`.
- **slow_inputs**: Full inputs for anomalous calls. Columns: `id`, `trace_id` (FK to traces), `input_json`, `created_at`. Cascading delete when a trace is removed.

Indexes on `tool_name`, `timestamp`, and `is_anomaly` keep queries fast.

## Query Tools

Four built-in query scripts for inspecting trace data:

### trace-view

```bash
bun scripts/trace-view.js                          # last 50 traces, all tools
bun scripts/trace-view.js --tool echo              # filter by tool
bun scripts/trace-view.js --slow-only              # anomalies only
bun scripts/trace-view.js --tool delay --limit 10  # combine filters
```

Returns JSON with trace fields. Useful for ad-hoc debugging.

### stats

```bash
bun scripts/stats.js --tool delay
```

Returns `ToolStats` for a tool:

```json
{ "toolName": "delay", "mean": 501.2, "stdDev": 12.4, "count": 42 }
```

### slow-inputs

```bash
bun scripts/slow-inputs.js                # all slow inputs
bun scripts/slow-inputs.js --tool echo    # filter by tool
```

Joins `slow_inputs` with `traces` to return the full input, tool name, duration, and timestamp for each recorded anomaly.

### trace-clean

```bash
bun scripts/trace-clean.js --older-than 30
```

Deletes traces (and their slow_inputs via cascade) older than N days. Returns the count of deleted rows.

## PureScript FFI Notes

PureScript FFI functions exported from `.js` files follow curried conventions. When calling a three-argument PureScript function from JS:

```js
// PureScript: handleAnomaly :: Db -> String -> Number -> String -> Effect AnomalyResult
// JS call chain (each arrow is one curried return):
Anomaly.handleAnomaly(db)(toolName)(durationMs)(inputJson)()
//                                                          ^^ final () invokes the Effect
```

The same pattern applies to `Tracer.writeTrace(db)(toolName)(durationMs)(inputJson)()`, `SQLiteCompat.getQuery(db)(sql)(params)()`, and so on.
