# Troubleshooting: oh-my-openagent Config

## Plugin Log (FIRST place to look)

```
/tmp/oh-my-opencode.log
```

Filter for config events:

```bash
grep -E "Config loaded|Partial config|Config validation|Final merged" /tmp/oh-my-opencode.log | tail -10
```

Healthy load:
```
Config loaded from /home/.../oh-my-openagent.json {"agents":{"sisyphus":{...},...}}
Final merged config {"agents":{...}}
```

Broken load (validation failed):
```
Config validation error in .../oh-my-openagent.json: [{"code":"invalid_value",...}]
Partial config loaded - invalid sections skipped: ["agents: ..."]
Partial config loaded from .../oh-my-openagent.json {}    # ← EMPTY = fallback chains kick in
Final merged config {}
```

## Failure Mode: Hardcoded Fallback Chains

When user config fails to load (or section is dropped), the plugin falls back to **hardcoded `AGENT_MODEL_REQUIREMENTS` chains** in the binary. These reference models across many providers (`opencode/gpt-5-nano`, `opencode/big-pickle`, `anthropic/claude-opus-4-6`, etc.).

### Symptom Cascade

1. Invalid config value (e.g. `reasoningEffort: "max"`) → schema validation fails
2. `parseConfigPartially` drops entire `agents`/`categories` section
3. Plugin uses fallback chain to assign models
4. `connected-providers-cache` (stale) tells plugin "provider X is connected"
5. Plugin picks `opencode/gpt-5-nano` from chain
6. `opencode.jsonc` has `disabled_providers: ["opencode"]` → "Model not found"

### Diagnostic Commands

```bash
# 1. Check config load status
grep "Config loaded\|Partial config" /tmp/oh-my-opencode.log | tail -3

# 2. See what model each agent resolves to
opencode debug config | jq '.agent | to_entries | map({name: .key, model: .value.model})'

# 3. See available models (after disabled_providers filter)
opencode models

# 4. Check connected-providers cache (stale = bug source)
cat ~/.cache/oh-my-openagent/connected-providers.json

# 5. Debug specific agent
opencode debug agent <name>
```

## Common Schema Traps

### 1. Filename Mismatch (CRITICAL)

| Wrong | Right |
|-------|-------|
| `~/.config/opencode/oh-my-opencode.json` | `~/.config/opencode/oh-my-openagent.json` |

The `$schema` URL is `https://raw.githubusercontent.com/code-yeongyu/oh-my-opencode/dev/...` — this references the REPO name, not the config filename. The plugin package `oh-my-openagent` reads `oh-my-openagent.json`.

Verify via plugin log: `grep "Config loaded from" /tmp/oh-my-opencode.log` — must show `oh-my-openagent.json`.

### 2. `reasoningEffort` Enum Restriction

| Source | Valid Values |
|--------|--------------|
| Dev schema URL | `none \| minimal \| low \| medium \| high \| xhigh \| max` |
| **Installed plugin 3.x binary** | `none \| minimal \| low \| medium \| high \| xhigh` (NO `max`) |

**Always use `xhigh` instead of `max`** — Z.ai API aliases `xhigh`→`max` internally.

### 3. `git_master` Required Property (Dev Schema)

Dev schema requires `git_master` at top level. Installed plugin does NOT enforce this. Pre-existing working configs fail dev-schema validation but function correctly.

### 4. Project-local Config Path

Wrong: `<project-root>/oh-my-openagent.json`
Right: `<project-root>/.opencode/oh-my-openagent.json`

Project config goes inside `.opencode/` subdir, not at project root.

## Provider Lockdown Pattern

To restrict agents to a single provider (e.g. only `zai-coding-plan`):

```jsonc
// opencode.jsonc (opencode core config)
{
  "disabled_providers": ["opencode", "github-copilot", "zai2"]
}

// oh-my-openagent.json (plugin config)
{
  "model_fallback": false,
  "runtime_fallback": { "enabled": false },
  "agents": { ... all set to zai-coding-plan/glm-5.2 ... }
}
```

### Why Both Files?

| File | Field Effect |
|------|--------------|
| `opencode.jsonc` `disabled_providers` | Hides models from `opencode models` list (opencode core) |
| `oh-my-openagent.json` `model_fallback: false` | Prevents cross-provider fallback at plugin level |
| `oh-my-openagent.json` `runtime_fallback.enabled: false` | Disables HTTP-error-triggered fallback |

⚠️ Plugin's internal `availableModels` set is separate from opencode core's. `disabled_providers` in opencode.jsonc does NOT affect plugin's view. Only explicit agent model assignment + `model_fallback: false` prevents the plugin from picking other-provider models when chain kicks in.

## Verification Checklist

After any config change:

1. **JSON syntax**: `python3 -c "import json; json.load(open('oh-my-openagent.json'))"`
2. **Plugin loads it**: `grep "Config loaded" /tmp/oh-my-opencode.log | tail -1` — must show non-empty agents map
3. **No "Partial config"**: `grep "Partial config loaded" /tmp/oh-my-opencode.log | tail -1` — should be absent or old
4. **Agent models correct**: `opencode debug agent sisyphus | jq '.model'` — must show configured model
5. **Available models**: `opencode models` — should show only allowed providers

## Recovery From Broken State

If agents are using fallback models despite correct config:

```bash
# 1. Find the schema validation error
grep "Config validation error" /tmp/oh-my-opencode.log | tail -1 | jq .

# 2. Fix the invalid field(s) per error details

# 3. Force plugin reload (next opencode invocation reads fresh)
opencode debug config > /dev/null

# 4. Verify reload
grep "Config loaded" /tmp/oh-my-opencode.log | tail -1
```
