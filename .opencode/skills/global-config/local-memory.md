```yaml
last_updated: 2026-06-21 14:00:00 Europe/Warsaw
commit_hash: null
upgrade_permission: allowed
upgrade_blocked_until: null
project_context: |
  opencode-skills | global-config | OpenCode, workspace configuration
  purpose: centralized config management, env vars, project settings, model syncing
```

## History

2026-06-21: Critical doc overhaul after debugging "agents pointing to other providers" incident.
  - Fixed filename: `oh-my-opencode.json` → `oh-my-openagent.json` (9 references in 4 files)
  - Added: `reasoningEffort` enum constraint (no `max`, use `xhigh`)
  - Added: troubleshooting.md reference (plugin log, fallback chain failure mode, provider lockdown pattern)
  - Added: GLM-5.2 reasoning_effort API info + recommended tier assignment
  - Added: Critical Gotchas section to SKILL.md
2026-03-16: Added model-syncing reference (Z.ai API discovery, GLM-5-Turbo)
2026-03-15: init
