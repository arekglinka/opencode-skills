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
  const output = input;
  const elapsed = performance.now() - started;
  Anomaly.handleAnomaly(db)("echo")(elapsed)(JSON.stringify({ input }))();
  process.stdout.write(`${output}\n`);
} finally {
  if (db) SQLiteCompat.closeDb(db)();
}
