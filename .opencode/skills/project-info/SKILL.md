---
name: project-info
description: Lazy project information extractor. Queries README files on-demand via explore agent.
license: MIT
compatibility: opencode
---

## Intent

Lightweight project information provider. Extracts details from README files on-demand with caching.

## Structure

```
project-info/SKILL.md     # orchestration (this file)
└── scripts/
    └── project-query.py    # README query interface
```

## Rules

| Field | Constraint |
|-------|------------|
| query_type | install|usage|commands|badges|all |
| cache_ttl | Duration for cache validity (default: 3600s) |

## Local Memory

`local-memory.md` tracks query history and cache:

```yaml
last_updated: <dt>
commit_hash: <sha>
cache_state: <map_of_projects>
project_context: <notes>
```

## Commands

| Category | Command | Description |
|----------|---------|-------------|
| query | `info <project> <key>` | Extract info from README (caches results) |
| invalidate | `info invalidate <project>` | Clear cache for project |
| ls | `info ls` | List all cached projects |

## Architecture

**Lazy evaluation**:

1. **Check cache** - If recent (<1 hr), return cached data
2. **Delegate to explore** - On cache miss, ask explore agent to parse README
3. **Extract sections** - Get install, usage, commands, badges based on query_type
4. **Update cache** - Store results with timestamp
5. **Return results** - JSON format for automation

This keeps the skill lightweight - only orchestration and caching logic, no parsing rules.

## Refs

- [readme patterns](.opencode/skills/readme-auditor/references/validation-rules.md) - How READMEs are structured
