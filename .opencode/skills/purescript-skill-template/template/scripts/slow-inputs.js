#!/usr/bin/env bun

import * as Tracer from "../output/Tracer/index.js";
import * as SQLiteCompat from "../output/SQLiteCompat/index.js";

function parseArgs(argv) {
  const args = { tool: null };
  for (let i = 0; i < argv.length; i += 1) {
    if (argv[i] === "--tool") {
      args.tool = argv[i + 1] ?? null;
      i += 1;
    }
  }
  return args;
}

const dbPath = process.env.TRACES_DB ?? "./traces.db";
const args = parseArgs(process.argv.slice(2));

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

  const where = args.tool ? "WHERE t.tool_name = ?" : "";
  const params = args.tool ? [args.tool] : [];
  const sql = `SELECT s.id, s.trace_id, t.tool_name, t.duration_ms, t.timestamp, s.input_json, s.created_at FROM slow_inputs s JOIN traces t ON t.id = s.trace_id ${where} ORDER BY s.id DESC`;
  const rows = SQLiteCompat.getQuery(db)(sql)(params)();

  process.stdout.write(`${JSON.stringify(rows, null, 2)}\n`);
} finally {
  if (db) SQLiteCompat.closeDb(db)();
}
