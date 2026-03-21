import { Database } from "bun:sqlite";

export function openDb(path) {
  const db = new Database(path);
  db.exec("PRAGMA foreign_keys = ON");
  db.exec("PRAGMA journal_mode = WAL");
  return db;
}

export function runQuery(db) {
  return function (sql) {
    return function (params) {
      const stmt = db.prepare(sql);
      stmt.run(...(params || []));
      return true;
    };
  };
}

export function getQuery(db) {
  return function (sql) {
    return function (params) {
      const stmt = db.prepare(sql);
      return stmt.all(...(params || []));
    };
  };
}

export function closeDb(db) {
  db.close();
}
