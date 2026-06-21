# Local Config Overrides

## Two-Layer Config Merge

oh-my-opencode merges configs: **global** (user-level) → **local** (project-level). Local overrides global. Global should NOT reference project-local agents.

| Layer | Path | Scope | Commit? |
|-------|------|-------|---------|
| Global | `~/.config/opencode/oh-my-openagent.json` | All projects | No |
| Local | `<project-root>/oh-my-openagent.json` | Current project only | Yes |

Merge: `deepMerge(global, local)` — local keys win on conflict.

## Local Agent Config

Project-local agents (`.opencode/agents/*.md`) need model assignment via local config:

```json
{
  "agents": {
    "quant": {
      "model": "zai-coding-plan/glm-5"
    },
    "custom-agent": {
      "model": "zai-coding-plan/glm-5-turbo",
      "variant": "high"
    }
  }
}
```

### Why Not Global?

| Approach | Problem |
|----------|---------|
| Add local agent to global `agents` map | Global shouldn't know project-specific agents; leaks across repos |
| Model in agent `.md` frontmatter only | May be ignored by oh-my-opencode's `applyAgentConfig` which replaces agent registry |

The correct pattern: frontmatter defines the agent, local config assigns the model.

## Minimal Local Config

Only include what differs from global. Empty sections are valid:

```json
{
  "agents": {
    "quant": { "model": "zai-coding-plan/glm-5" }
  }
}
```

No `categories`, no `$schema` — those come from global.

## Category Overrides

Same merge for categories:

```json
{
  "agents": {
    "quant": { "model": "zai-coding-plan/glm-5" }
  },
  "categories": {
    "deep": {
      "model": "zai-coding-plan/glm-5",
      "variant": "max"
    }
  }
}
```

## Validation

| Check | Method |
|-------|--------|
| Valid JSON | `python3 -c "import json; json.load(open('oh-my-openagent.json'))"` |
| Plugin loads cfg | `grep "Config loaded from\|Partial config" /tmp/oh-my-opencode.log \| tail -3` (expect non-empty agents map, NOT `{}`) |
| Local loads | Restart opencode, check agent model in session info |
| No global leak | Verify `~/.config/opencode/oh-my-openagent.json` has no project-local agent names |
