---
name: global-config
description: Manages OpenCode and oh-my-openagent configuration. Use for installing, updating, and managing LSP servers, agent models, and config files.
license: MIT
compatibility: opencode
---

## Intent

Generic cfg manager for OpenCode + oh-my-openagent.

## Critical Gotchas (READ FIRST)

| Trap | Right |
|------|-------|
| Config filename | `~/.config/opencode/oh-my-openagent.json` (NOT `oh-my-opencode.json` despite schema URL) |
| `reasoningEffort` enum | Use `xhigh` not `max` (plugin 3.x rejects `max`; API aliases `xhigh`→`max`) |
| Validation failure | Single invalid field drops the ENTIRE section → plugin uses hardcoded fallback chains |
| Debug log | `/tmp/oh-my-opencode.log` — `grep "Config loaded\|Partial config" | tail -3` |
| Schema URL vs binary | Dev-branch schema shows fields/enums the installed binary may reject — always test with `opencode debug config` |

## Structure

```
global-config/SKILL.md     # core skill
├── scripts/               # optional: helper scripts
├── references/            # optional: schemas, examples
└── assets/                # optional: configs, templates
```

## Rules

| Field | Constraint |
|-------|------------|
| config_path | Valid file path, relative/absolute |
| value_type | str|int|bool|list|map |
| command | list|get|set|validate|backup|restore |

## Local Memory

`local-memory.md` tracks cfg state:

```yaml
last_updated: <dt>
commit_hash: <sha>
cfg_hash: <sha>
backup_location: <path>
project_context: <notes>
```

## Commands

| Category | Command | Description |
|----------|---------|-------------|
| list | `cfg ls` | List all cfg files |
| get | `cfg get <key>` | Retrieve cfg value |
| set | `cfg set <key> <val>` | Set cfg value |
| validate | `cfg validate` | Verify cfg syntax + plugin loads it (grep `/tmp/oh-my-opencode.log` for "Config loaded") |
| backup | `cfg backup` | Save cfg state |
| restore | `cfg restore` | Load cfg state |
| sync | `cfg sync-models` | Sync provider models from API |

## Compression

| Technique | Example |
|-----------|---------|
| Abbreviate | `config→cfg`, `settings→stgs` |
| Inline | `Must be 1-64 chars` → `1-64c` |
| Single-line | `a\nb\nc` → `a \| b \| c` |
| Pipe map | `opt1: val1` → `opt1→val1` |

**Target**: <70 lines | extended → `references/`

## Refs

- [troubleshooting](references/troubleshooting.md) — **start here for config load failures**
- [agent-setup](references/agent-setup.md)
- [config-files](references/config-files.md)
- [model-syncing](references/model-syncing.md)
- [local-config](references/local-config.md)
