#!/usr/bin/env bun

import * as Tracer from "../output/Tracer/index.js";
import * as SQLiteCompat from "../output/SQLiteCompat/index.js";
import * as Statistics from "../output/Statistics/index.js";

function usage() {
  process.stderr.write("Usage: bun scripts/stats.js --tool name\n");
}

function parseArgs(argv) {
  let tool = null;
  for (let i = 0; i < argv.length; i += 1) {
    if (argv[i] === "--tool") {
      tool = argv[i + 1] ?? null;
      i += 1;
    }
  }
  return { tool };
}

const dbPath = process.env.TRACES_DB ?? "./traces.db";
const { tool } = parseArgs(process.argv.slice(2));

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

if (!tool) {
  usage();
  process.exit(1);
}

let db;
try {
  db = openOrInitDb(dbPath);
  const rows = SQLiteCompat.getQuery(db)("SELECT duration_ms FROM traces WHERE tool_name = ? ORDER BY id DESC")([tool])();
  const durations = rows.map((row) => row.duration_ms);
  const stats = Statistics.getToolStats(tool)(durations);
  process.stdout.write(`${JSON.stringify(stats, null, 2)}\n`);
} finally {
  if (db) SQLiteCompat.closeDb(db)();
}
