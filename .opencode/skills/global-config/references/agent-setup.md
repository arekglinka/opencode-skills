# Agent Setup Reference

## Discovery

OpenCode discovers agents via glob `{agent,agents}/**/*.md` in `.opencode/`.

## Directory Structure (Required for Visibility)

oh-my-opencode plugin replaces the agent registry on load. Agents only appear if discovered via the glob. A **bare `.md` file alone may not be visible** — a subdirectory with at least one file is needed.

```
.opencode/agents/
├── agent-name.md              # main agent definition (frontmatter + prompt)
└── agent-name/
    └── variant.md             # sub-agent / reference (no frontmatter needed)
```

## Frontmatter Schema

```yaml
---
description: <str, 1-1024c, shown in agent list>
mode: subagent
model: <str, provider/model-id>
temperature: <float, 0.0-2.0>
tools:
  read: true
  edit: true
  glob: true
  grep: true
  bash: true
---
```

### Fields

| Field | Required | Notes |
|-------|----------|-------|
| `description` | Yes | Agent picker label |
| `mode` | No | `subagent` for callable agents |
| `model` | No | Overrides default model |
| `temperature` | No | Default varies by agent |
| `tools` | No | Boolean map of allowed tools |
| `permission` | No | Newer alt: `read: allow\|deny\|ask` |
| `hidden` | No | Hide from agent picker |

### Valid Tool Names

`read`, `edit`, `glob`, `grep`, `list`, `bash`, `task`, `webfetch`, `websearch`, `codesearch`, `lsp`, `todowrite`, `question`, `skill`

> Note: `write` is NOT a valid tool — use `edit`.

## oh-my-opencode Interaction

The plugin's `applyAgentConfig` replaces `config.agent` entirely. Custom agents from `.opencode/agents/` are preserved via `filteredConfigAgents` unless:

1. Agent name conflicts with a builtin (`sisyphus`, `oracle`, `explore`, etc.)
2. Agent name is in `disabled_agents` in `oh-my-opencode.json`

### call_omo_agent Allowlist

The `task(subagent_type=...)` tool is gated by a hardcoded allowlist in oh-my-opencode:

```
explore, librarian, oracle, hephaestus, metis, momus, multimodal-looker
```

Custom agents NOT in this list can't be spawned via `task(subagent_type="...")`.
Use `category`-based delegation instead: `task(category="deep", prompt="...")`.

## Model Overrides

In `oh-my-opencode.json`:
```json
{
  "agents": {
    "agent-name": { "model": "provider/model-id", "variant": "high" }
  }
}
```

## Naming

| Convention | Example |
|-----------|---------|
| Lowercase, no spaces | `quant.md` |
| Subdirectory for variants | `quant/guardian.md` |
| Hyphens in sub-agent names | `quant/guardian-leakage.md` |
| No special chars | `[^a-z0-9/._-]` not recommended |

## Common Pitfalls

| Issue | Cause | Fix |
|-------|-------|-----|
| Agent not visible | Single `.md` with no subdirectory | Add `<name>/` dir with ≥1 file |
| Agent not callable via `task()` | Not in `ALLOWED_AGENTS` | Use `category` delegation |
| Agent conflicts with builtin | Same name as oh-my-opencode builtin | Rename agent |
| Invalid tool name | `write` or unknown tool | Use `edit` instead |
| Frontmatter parse error | Invalid YAML or missing `---` delimiters | Validate YAML syntax |
