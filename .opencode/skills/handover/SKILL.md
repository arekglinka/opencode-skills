---
name: handover
description: Extracts session context into a handoff file for seamless continuation in a new session. Use at end of session or when context is getting too long.
---

Extracts context from current session and writes it to `.handoff/<unix_ts>.md`.

## Protocol

### Saving (end of current session)

1. Gather context in parallel:
   - `session_read(session_id)` — full history + todos
   - `git status --porcelain` — uncommitted changes
   - `git diff HEAD --stat` — staged/unstaged diff stats
   - `git log --oneline -5` — recent commits
2. Synthesize into handoff using format in `references/format.md`
3. Write to `.handoff/<unix_ts>.md` (seconds since epoch)
4. Cleanup: keep only the 2 most recent files (current + 1 backup)
5. Print continuation instructions

### Loading (start of new session)

When user pastes a handoff or says "continue from handoff":
1. Glob `.handoff/*.md` — find all handoff files
2. If multiple: read the newest, delete all others
3. If single: read it, no cleanup needed
4. Parse timestamp from first line (`# HANDOFF <unix_ts>`)
5. Print summary of what was handed off
6. Continue with user's request

## Rules

| Field | Value |
|-------|-------|
| dir | `.handoff/` (project-local) |
| filename | `<unix_ts>.md` |
| max files | 2 (current + 1 backup) |
| timestamp | first line: `# HANDOFF <unix_ts>` |
| encoding | plain text, no markdown rendering |

## Compression targets

- SKILL.md: <50 lines (protocol + rules) | format template in `references/`
- Output file: focused, <200 lines when possible
- USER REQUESTS: verbatim only | CONSTRAINTS: verbatim only

## Refs

- [format](references/format.md) — output template + section rules
