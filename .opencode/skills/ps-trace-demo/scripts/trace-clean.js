#!/usr/bin/env bun

import * as Tracer from "../output/Tracer/index.js";
import * as SQLiteCompat from "../output/SQLiteCompat/index.js";

function parseArgs(argv) {
  let olderThan = null;
  for (let i = 0; i < argv.length; i += 1) {
    if (argv[i] === "--older-than") {
      olderThan = Number.parseInt(argv[i + 1] ?? "", 10);
      i += 1;
    }
  }
  return { olderThan };
}

const dbPath = process.env.TRACES_DB ?? "./traces.db";
const { olderThan } = parseArgs(process.argv.slice(2));

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

if (olderThan == null || !Number.isFinite(olderThan) || olderThan <= 0) {
  process.stderr.write("Usage: bun scripts/trace-clean.js --older-than N\n");
  process.exit(1);
}

let db;
try {
  db = openOrInitDb(dbPath);
  const deleted = Tracer.deleteOldTraces(db)(olderThan)();
  process.stdout.write(`{"deleted": ${deleted}}\n`);
} finally {
  if (db) SQLiteCompat.closeDb(db)();
}
