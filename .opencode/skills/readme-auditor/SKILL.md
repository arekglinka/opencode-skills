---
name: readme-auditor
description: README validation and updating framework. Orchestrates README checks via dedicated agents.
license: MIT
compatibility: opencode
---

## Intent

Orchestration layer for README validation and content extraction. Uses meta-skill pattern to delegate work to explore agent.

## Structure

```
readme-auditor/SKILL.md     # orchestration (this file)
└── references/            # reusable patterns, workflows
    ├── validation-rules.md
    └── quick-start.md
```

## Rules

| Field | Constraint |
|-------|------------|
| readme_path | Valid file path (README.md, docs/README.md) |
| check_type | links|sections|todo|consistency|all |
| update_mode | auto|interactive|dry-run |

## Local Memory

`local-memory.md` tracks audit history:

```yaml
last_updated: <dt>
commit_hash: <sha>
audit_results: <map_of_files>
project_context: <notes>
```

## Commands

| Category | Command | Description |
|----------|---------|-------------|
| check | `readme check <path>` | Validate single README |
| audit | `readme audit` | Check all READMEs in project |
| extract | `readme extract <path> <key>` | Extract info from README (lazy) |

## Architecture

**Meta-skill pattern** for durability:

1. **SKILL.md** - Orchestration only (minimal content)
2. **References/** - Detailed rules (external, updateable separately)
3. **Delegates** to `explore` agent for README parsing
4. **Caches** results for performance

This avoids content obsolescence - rules live in references/, not in SKILL.md.

## Refs

- [validation rules](references/validation-rules.md) - Detailed issue detection
- [quick start](references/quick-start.md) - Usage examples and workflows
