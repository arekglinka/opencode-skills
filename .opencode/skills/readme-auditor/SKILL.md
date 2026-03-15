---
name: readme-auditor
description: Validates and updates README.md files. Checks for outdated content, broken links, and consistency with project state.
license: MIT
compatibility: opencode
---

## Intent

Automated README validation and updating for skill repositories.

## Structure

```
readme-auditor/SKILL.md     # core skill
├── scripts/               # helper scripts
└── references/            # validation rules, common patterns
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
| update | `readme update <path>` | Update outdated sections |
| fix-links | `readme fix-links <path>` | Validate/correct broken links |
| sections | `readme sections <path>` | Show section structure |

## Compression

| Technique | Example |
|-----------|---------|
| Abbreviate | `markdown→md`, `installation→inst` |
| Inline | `See section X` → `§X` |
| Single-line | `a\nb\nc` → `a \| b \| c` |
| Pipe map | `opt1: val1` → `opt1→val1` |

**Target**: <70 lines | extended → `references/`

## Refs

- [validation rules](references/validation-rules.md)
- [section patterns](references/sections.md)
- [common fixes](references/common-fixes.md)
