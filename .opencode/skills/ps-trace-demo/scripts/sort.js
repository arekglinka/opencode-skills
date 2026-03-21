#!/usr/bin/env bun

import * as Tracer from "../output/Tracer/index.js";
import * as Anomaly from "../output/Anomaly/index.js";
import * as SQLiteCompat from "../output/SQLiteCompat/index.js";

function usage() {
  process.stderr.write("Usage: bun scripts/sort.js \"[3,1,2,5,4]\"\n");
}

const dbPath = process.env.TRACES_DB ?? "./traces.db";
const raw = process.argv[2];

if (!raw) {
  usage();
  process.exit(1);
}

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
  const input = JSON.parse(raw);
  if (!Array.isArray(input)) {
    process.stderr.write("Error: input must be a JSON array\n");
    process.exit(1);
  }
  db = openOrInitDb(dbPath);
  const started = performance.now();
  const sorted = [...input].sort((a, b) => a - b);
  const elapsed = performance.now() - started;
  Anomaly.handleAnomaly(db)("sort")(elapsed)(JSON.stringify({ itemCount: input.length }))();
  process.stdout.write(`${JSON.stringify({ sorted, itemCount: input.length, durationMs: Math.round(elapsed * 100) / 100 })}\n`);
} catch (err) {
  if (!db) {
    process.stderr.write(`Error: ${err?.message ?? err}\n`);
    process.exit(1);
  }
  throw err;
} finally {
  if (db) SQLiteCompat.closeDb(db)();
}
