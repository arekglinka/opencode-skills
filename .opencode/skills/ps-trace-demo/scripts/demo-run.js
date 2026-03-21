#!/usr/bin/env bun

import * as Tracer from "../output/Tracer/index.js";
import * as Anomaly from "../output/Anomaly/index.js";
import * as SQLiteCompat from "../output/SQLiteCompat/index.js";

const dbPath = process.env.TRACES_DB ?? "./traces.db";

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
  process.stdout.write("=== ps-trace-demo: Full Pipeline Demo ===\n\n");

  process.stdout.write("[1/5] Checking existing trace count...\n");
  const beforeCount = SQLiteCompat.getQuery(db)("SELECT COUNT(*) AS count FROM traces")([])();
  process.stdout.write(`  Traces before: ${beforeCount[0].count}\n\n`);

  process.stdout.write("[2/5] Seeding 100 normal hash calls (calibration)...\n");
  for (let i = 0; i < 100; i++) {
    const started = performance.now();
    const dummy = `seed-${i}`;
    for (let j = 0; j < dummy.length; j++) { dummy.charCodeAt(j); }
    const elapsed = performance.now() - started;
    Anomaly.handleAnomaly(db)("demo")(elapsed)(JSON.stringify({ type: "calibration", index: i }))();
  }
  process.stdout.write(`  Seeded 100 calibration calls\n\n`);

  process.stdout.write("[3/5] Running normal tool calls (hash, sort)...\n");
  const hashStart = performance.now();
  const hashInput = "hello ps-trace-demo";
  let hash = 0;
  for (let i = 0; i < hashInput.length; i++) {
    hash = ((hash << 5) - hash + hashInput.charCodeAt(i)) | 0;
  }
  const hashElapsed = performance.now() - hashStart;
  const hashResult = Anomaly.handleAnomaly(db)("demo-hash")(hashElapsed)(JSON.stringify({ input: hashInput }))();

  const sortStart = performance.now();
  const arr = Array.from({ length: 1000 }, (_, i) => Math.random());
  arr.sort((a, b) => a - b);
  const sortElapsed = performance.now() - sortStart;
  const sortResult = Anomaly.handleAnomaly(db)("demo-sort")(sortElapsed)(JSON.stringify({ itemCount: 1000 }))();

  process.stdout.write(`  demo-hash: ${Math.round(hashElapsed * 100) / 100}ms (anomaly: ${hashResult.isAnomaly})\n`);
  process.stdout.write(`  demo-sort: ${Math.round(sortElapsed * 100) / 100}ms (anomaly: ${sortResult.isAnomaly})\n\n`);

  process.stdout.write("[4/5] Injecting anomalous slow call...\n");
  const slowStart = performance.now();
  await Bun.sleep(50);
  const slowElapsed = performance.now() - slowStart;
  const slowResult = Anomaly.handleAnomaly(db)("demo")(slowElapsed)(JSON.stringify({ type: "anomaly-injection", sleepMs: 50 }))();
  process.stdout.write(`  Slow call: ${Math.round(slowElapsed * 100) / 100}ms\n`);
  process.stdout.write(`  Anomaly detected: ${slowResult.isAnomaly}\n`);
  process.stdout.write(`  Z-score: ${Math.round(slowResult.zScore * 100) / 100}\n\n`);

  process.stdout.write("[5/5] Querying results...\n");
  const totalTraces = SQLiteCompat.getQuery(db)("SELECT COUNT(*) AS count FROM traces")([])();
  const anomalyTraces = SQLiteCompat.getQuery(db)("SELECT COUNT(*) AS count FROM traces WHERE is_anomaly = 1")([])();
  const slowInputs = SQLiteCompat.getQuery(db)("SELECT COUNT(*) AS count FROM slow_inputs")([])();
  const demoStats = SQLiteCompat.getQuery(db)("SELECT duration_ms FROM traces WHERE tool_name = 'demo' ORDER BY id DESC LIMIT 100")([])();
  const durations = demoStats.map((r) => r.duration_ms);
  const mean = durations.reduce((s, v) => s + v, 0) / durations.length;

  process.stdout.write(`  Total traces: ${totalTraces[0].count}\n`);
  process.stdout.write(`  Anomalies: ${anomalyTraces[0].count}\n`);
  process.stdout.write(`  Slow inputs captured: ${slowInputs[0].count}\n`);
  process.stdout.write(`  Demo tool mean: ${Math.round(mean * 100) / 100}ms\n\n`);

  process.stdout.write("=== Demo complete ===\n");
  process.stdout.write("Run these to explore:\n");
  process.stdout.write("  bun scripts/trace-view.js --slow-only\n");
  process.stdout.write("  bun scripts/stats.js --tool demo\n");
  process.stdout.write("  bun scripts/slow-inputs.js\n");
} finally {
  if (db) SQLiteCompat.closeDb(db)();
}
