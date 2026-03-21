-- SQLite schema for tool-call tracing
-- Version 1

PRAGMA foreign_keys = ON;

CREATE TABLE _schema_meta (
  key TEXT PRIMARY KEY,
  value TEXT
);

INSERT INTO _schema_meta VALUES ('version', '1');

CREATE TABLE traces (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  tool_name TEXT NOT NULL,
  timestamp TEXT NOT NULL DEFAULT (datetime('now')),
  duration_ms REAL NOT NULL,
  input_json TEXT,
  input_hash TEXT,
  is_anomaly INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE slow_inputs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  trace_id INTEGER NOT NULL REFERENCES traces(id) ON DELETE CASCADE,
  input_json TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX idx_traces_tool_name ON traces(tool_name);
CREATE INDEX idx_traces_timestamp ON traces(timestamp);
CREATE INDEX idx_traces_is_anomaly ON traces(is_anomaly);
CREATE INDEX idx_slow_inputs_trace_id ON slow_inputs(trace_id);
