#!/usr/bin/env bun

import * as Tracer from "../output/Tracer/index.js";
import * as Anomaly from "../output/Anomaly/index.js";
import * as SQLiteCompat from "../output/SQLiteCompat/index.js";
import * as Hasher from "../output/Hasher/index.js";

function usage() {
  process.stderr.write("Usage: bun scripts/hash.js \"text to hash\"\n");
}

const dbPath = process.env.TRACES_DB ?? "./traces.db";
const input = process.argv.slice(2).join(" ");

if (!input) {
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
  db = openOrInitDb(dbPath);
  const started = performance.now();
  const result = Hasher.computeHash(input).value0;
  const elapsed = performance.now() - started;
  Anomaly.handleAnomaly(db)("hash")(elapsed)(JSON.stringify({ input, length: input.length }))();
  process.stdout.write(`${JSON.stringify({ input: result.input, length: result.inputLength, hash: result.hashValue, hex: result.hashHex, durationMs: Math.round(elapsed * 100) / 100 })}\n`);
} finally {
  if (db) SQLiteCompat.closeDb(db)();
}
