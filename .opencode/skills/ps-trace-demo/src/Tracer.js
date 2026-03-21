import { readFileSync } from "node:fs";
import { resolve } from "node:path";

export function readSchemaFile() {
  const path = resolve(import.meta.dir, "../../references/schema.sql");
  return readFileSync(path, "utf8");
}
