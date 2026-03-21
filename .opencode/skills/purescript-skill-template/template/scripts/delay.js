#!/usr/bin/env bun

import * as Tracer from "../output/Tracer/index.js";
import * as Anomaly from "../output/Anomaly/index.js";
import * as SQLiteCompat from "../output/SQLiteCompat/index.js";

function usage() {
  process.stderr.write("Usage: bun scripts/delay.js N\n");
}

const dbPath = process.env.TRACES_DB ?? "./traces.db";
const ms = Number.parseInt(process.argv[2] ?? "", 10);

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

if (!Number.isFinite(ms) || ms < 0) {
  usage();
  process.exit(1);
}

let db;
try {
  db = openOrInitDb(dbPath);
  const started = performance.now();
  await Bun.sleep(ms);
  const elapsed = performance.now() - started;
  Anomaly.handleAnomaly(db)("delay")(elapsed)(JSON.stringify({ ms }))();
  process.stdout.write(`${JSON.stringify({ sleptMs: ms, durationMs: elapsed })}\n`);
} finally {
  if (db) SQLiteCompat.closeDb(db)();
}
