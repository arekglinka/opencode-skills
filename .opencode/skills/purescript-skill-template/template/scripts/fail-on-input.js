#!/usr/bin/env bun

import * as Tracer from "../output/Tracer/index.js";
import * as Anomaly from "../output/Anomaly/index.js";
import * as SQLiteCompat from "../output/SQLiteCompat/index.js";

function usage() {
  process.stderr.write("Usage: bun scripts/fail-on-input.js \"input\" \"pattern\"\n");
}

const dbPath = process.env.TRACES_DB ?? "./traces.db";
const input = process.argv[2];
const pattern = process.argv[3];

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

if (input == null || pattern == null) {
  usage();
  process.exit(1);
}

let db;
let shouldFail = false;
try {
  db = openOrInitDb(dbPath);
  const started = performance.now();
  shouldFail = input.includes(pattern);
  const elapsed = performance.now() - started;
  Anomaly.handleAnomaly(db)("fail-on-input")(elapsed)(JSON.stringify({ input, pattern, shouldFail }))();
  if (shouldFail) {
    process.stderr.write(`Pattern matched: ${pattern}\n`);
    process.exitCode = 1;
  } else {
    process.stdout.write("OK\n");
  }
} finally {
  if (db) SQLiteCompat.closeDb(db)();
}
