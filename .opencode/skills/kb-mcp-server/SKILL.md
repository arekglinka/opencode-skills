---
name: kb-mcp-server
description: Manages the project-local Knowledge Base. Use when ingesting, loading, or importing knowledge sources (markdown dirs, PDFs), initializing .knowledge/, setting up MCP config, or troubleshooting KB connection errors.
---

Project-local Knowledge Base with 6 MCP tools: search_kb, get_page, get_glossary, get_references, list_categories, health.

## State

DB path in `.knowledge/config.json` (project-local) or `local-memory.md` (global fallback).
Scripts at `/home/ag/wsp/knowledge-base/scripts/`.

## Ingest Knowledge

When user says "ingest/load/import knowledge from X" — run loader, then ask about enrichment.

1. Read `.knowledge/config.json` for `db_path`. If missing, the KB is not initialized — run `kb-init.py` first.
2. Run the loader:
   ```bash
   python3 /home/ag/wsp/knowledge-base/scripts/load-md.py <db_path> <source_dir>
   ```
3. Report results (page count).
4. Ask user: "Generate glossary and cross-references from the loaded pages?"
   - **Yes** → run enrichment (see below)
   - **No** → done

**PDF**: use `scripts/load-afml.py <db_path>` (AFML book specific).

No restart needed — STDIO mode spawns a fresh container per request.

## Enrich (Glossary + Cross-References)

After loading pages, enrich the KB with auto-extracted glossary terms and semantic cross-references.

```bash
python3 /home/ag/wsp/knowledge-base/scripts/enrich-kb.py <db_path>
```

Flags: `--glossary-only` | `--refs-only` | `--topics <topics.json>`

What it does:
- **Glossary**: Extracts terms from `**BoldTerm** — definition` patterns in page content. Deduplicates by term name.
- **Cross-references**: Links pages sharing topic keywords (derived from path segments + headings). Threshold: words in 2–8 pages.
- **With `--topics`**: Uses a JSON file mapping topic keywords to path substrings for precise manual control.

For project-specific enrichment (custom glossary, precise topic maps), store scripts in `.sisyphus/scripts/` and call them from the agent — do not modify the KB scripts directory.

## Initialize KB

If `.knowledge/` doesn't exist in the project root:
```bash
python3 /home/ag/wsp/knowledge-base/scripts/kb-init.py --non-interactive --mode stdio --update-opencode
```

Creates `.knowledge/` with `kb.db` (empty schema), `config.json`, `session_id`. Updates `opencode.jsonc` with podman command pointing to the local DB. User must restart OpenCode after.

## Config

`opencode.jsonc` entry (type `"local"` for STDIO, `"remote"` for HTTP):

```jsonc
"knowledge-base": {
  "type": "local",
  "command": ["podman", "run", "--rm", "-i", "-v", "<db>:/data/wiki.db", "localhost/kb-mcp-server", "/data/wiki.db"],
  "timeout": 10000
}
```

HTTP mode: `"type": "remote"` with `"url": "http://localhost:<port>/mcp"`. Container runs in tmux. See `references/http-lifecycle.md`.

## Browse KB

Visually browse the Knowledge Base in a browser:
```bash
python3 /home/ag/wsp/knowledge-base/scripts/kb-serve.py <db_path>
```

Defaults to `.knowledge/kb.db` if no path given. Opens at `http://localhost:8080`. Features: page listing, markdown rendering, search, glossary, page tree. Dependencies: `mistune` (already installed).

## Troubleshooting

- **Connection error**: Check `.knowledge/kb.db` exists and `opencode.jsonc` path matches
- **No .knowledge/**: Run `kb-init.py` (see Initialize KB above)
- **Image missing**: `podman build -t localhost/kb-mcp-server .` from Haskell project
- **Config path wrong**: Re-run `kb-init.py` (paths are absolute, break on move)
- **Glossary/refs empty after enrichment**: Restart OpenCode — STDIO spawns fresh container per request
