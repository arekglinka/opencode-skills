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
| `oh-my-opencode.json` | Agent→model mapping | `agents.<name>.model` |

## Sync Workflow

```
1. Query /models API → get list
2. Test new model names if rumored/released
3. Update opencode.jsonc → add model entries
4. Update oh-my-opencode.json → assign to agents
5. Verify → run opencode auth list
```

## Z.ai Config Example

```json
{
  "provider": {
    "zai2": {
      "name": "zai2",
      "npm": "@ai-sdk/openai-compatible",
      "models": {
        "glm-4.5": { "name": "glm-4.5" },
        "glm-4.6": { "name": "glm-4.6" },
        "glm-4.7": { "name": "glm-4.7" },
        "glm-5": { "name": "glm-5" },
        "glm-5-turbo": { "name": "glm-5-turbo" }
      },
      "options": {
        "baseURL": "https://api.z.ai/api/coding/paas/v4"
      }
    }
  }
}
```

## Agent Model Assignment

| Agent | Recommended Model | Reason |
|-------|-------------------|--------|
| sisyphus | glm-5-turbo | Agent-optimized, tool calling |
| oracle | glm-5 | Deep reasoning |
| explore | glm-5-turbo | Fast codebase grep |
| librarian | glm-5-turbo | Fast doc search |
| prometheus | glm-5 | Strategic planning |

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
