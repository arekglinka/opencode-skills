#!/usr/bin/env bun

import * as Tracer from "../output/Tracer/index.js";
import * as SQLiteCompat from "../output/SQLiteCompat/index.js";

function parseArgs(argv) {
  const args = { tool: null, limit: 50, slowOnly: false };
  for (let i = 0; i < argv.length; i += 1) {
    const token = argv[i];
    if (token === "--tool") {
      args.tool = argv[i + 1] ?? null;
      i += 1;
    } else if (token === "--limit") {
      const n = Number.parseInt(argv[i + 1] ?? "", 10);
      if (Number.isFinite(n) && n > 0) args.limit = n;
      i += 1;
    } else if (token === "--slow-only") {
      args.slowOnly = true;
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

  const whereParts = [];
  const params = [];
  if (args.tool) {
    whereParts.push("tool_name = ?");
    params.push(args.tool);
  }
  if (args.slowOnly) {
    whereParts.push("is_anomaly = 1");
  }

  const whereClause = whereParts.length > 0 ? `WHERE ${whereParts.join(" AND ")}` : "";
  const sql = `SELECT id, tool_name, timestamp, duration_ms, COALESCE(input_json, '') AS input_json, COALESCE(input_hash, '') AS input_hash, is_anomaly FROM traces ${whereClause} ORDER BY id DESC LIMIT ?`;
  const rows = SQLiteCompat.getQuery(db)(sql)([...params, args.limit])();

  process.stdout.write(`${JSON.stringify(rows, null, 2)}\n`);
} finally {
  if (db) SQLiteCompat.closeDb(db)();
}
