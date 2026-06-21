# Model Syncing Reference

## Overview

Keep OpenCode model configs synced with provider APIs. Models change frequently—new releases, deprecations, access tier changes.

## Provider Model Discovery

### Z.ai Coding Plan

```bash
# List available models (official API)
curl -s "https://api.z.ai/api/coding/paas/v4/models" \
  -H "Authorization: Bearer $ZAI_API_KEY" \
  -H "Content-Type: application/json"

# Test unlisted model (may work even if not in /models)
curl -s "https://api.z.ai/api/coding/paas/v4/chat/completions" \
  -H "Authorization: Bearer $ZAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model": "glm-5-turbo", "messages": [{"role": "user", "content": "test"}], "max_tokens": 10}'
```

| Tier | Access | Models |
|------|--------|--------|
| Lite | Basic | glm-4.5, glm-4.6, glm-4.7, glm-5 (delayed) |
| Pro | Extended | +glm-5, glm-5-turbo (early access) |
| Max | Full | All models day-one |

### GitHub Copilot

```bash
# Via opencode auth
opencode auth list  # Check copilot status
```

Models routed via `github-copilot/` prefix—no direct API.

### OpenRouter

```bash
curl -s "https://openrouter.ai/api/v1/models" \
  -H "Authorization: Bearer $OPENROUTER_API_KEY"
```

## Config Files

| File | Purpose | Models Section |
|------|---------|----------------|
| `opencode.jsonc` | Provider definitions | `provider.<name>.models` |
| `oh-my-openagent.json` | Agent→model mapping | `agents.<name>.model` |

## Sync Workflow

```
1. Query /models API → get list
2. Test new model names if rumored/released
3. Update opencode.jsonc → add model entries
4. Update oh-my-openagent.json → assign to agents
5. Verify → run opencode auth list + check /tmp/oh-my-opencode.log for "Config loaded from"
```

## Z.ai Config

Use built-in `zai-coding-plan` provider (configured via `opencode auth login`). No manual provider definition needed.

Available models: `glm-4.5`, `glm-4.5-air`, `glm-4.6`, `glm-4.7`, `glm-5`, `glm-5-turbo`, `glm-5.1`, `glm-5.2`, `glm-5v-turbo`

## GLM-5.2 Reasoning (Exclusive Feature)

GLM-5.2 is the **only** GLM model that supports `reasoning_effort` parameter. Older models only have `thinking` on/off.

| `reasoningEffort` value | API behavior | Use for |
|---|---|---|
| `xhigh` | maps to API `max` (deep reasoning, default) | Strategic agents: sisyphus, oracle, prometheus, metis, momus, hephaestus |
| `high` | enhanced reasoning | Medium-tier: sisyphus-junior, atlas, vectorbt, visual-engineering, unspecified-high, writing |
| `medium`/`low` | maps to `high` | Rarely useful |
| `minimal`/`none` | skips thinking | Fast grep agents (use `thinking: { type: "disabled" }` instead) |

⚠️ Plugin 3.x enum rejects `max` — use `xhigh`. Z.ai API aliases `xhigh`→`max` internally.

GLM-5.2 has forced deep thinking enabled by default. Even without explicit config, responses include `reasoning_content` + `reasoning_tokens`.

## Agent Model Assignment (current best practice)

| Agent | Model | thinking | reasoningEffort |
|-------|-------|----------|-----------------|
| sisyphus, oracle, prometheus, metis, momus, hephaestus | glm-5.2 | enabled | xhigh |
| sisyphus-junior, multimodal-looker, atlas | glm-5.2 | enabled | high |
| librarian, explore | glm-5.2 | disabled | — |
| Categories: ultrabrain, artistry, deep | glm-5.2 | enabled | xhigh |
| Categories: visual-engineering, unspecified-high, writing | glm-5.2 | enabled | high |
| Categories: quick, unspecified-low | glm-5.2 | disabled | — |

## GLM-5 vs GLM-5-Turbo

| Feature | GLM-5 | GLM-5-Turbo |
|---------|-------|-------------|
| Release | Feb 2026 | Mar 2026 |
| Focus | General | OpenClaw/agent |
| Speed | Standard | Faster |
| Tool calling | Good | Optimized |
| Long-chain | Good | Enhanced |

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Model not listed | Test anyway—may work unlisted |
| 401 error | Re-auth: `opencode auth login` |
| Tier restriction | Upgrade subscription |
| Rate limited | Check usage dashboard |

## Auth File

Location: `~/.local/share/opencode/auth.json`

```json
{
  "zai-coding-plan": {
    "type": "api",
    "key": "xxx.yyy"
  }
}
```

## Re-run Installer

```bash
# Sync with latest oh-my-opencode defaults
bunx oh-my-opencode install --no-tui \
  --claude=<yes|no|max20> \
  --openai=<yes|no> \
  --gemini=<yes|no> \
  --copilot=<yes|no> \
  --zai-coding-plan=<yes|no>
```

## Sources

| Info | URL |
|------|-----|
| Z.ai docs | `docs.z.ai/guides/llm/glm-5` |
| Z.ai turbo | `docs.z.ai/guides/llm/glm-5-turbo` |
| Pricing | `z.ai/subscribe` |
| OpenRouter | `openrouter.ai/z-ai/glm-5-turbo` |
