```yaml
last_updated: 2026-03-15 14:48:00 Europe/Warsaw
commit_hash: f0bdccf478d048ff2161ba1af09460779593fec9
upgrade_permission: allowed
upgrade_blocked_until: null
project_context: |
  opencode-skills | global-config | OpenCode, workspace configuration
  purpose: centralized config management, env vars, project settings, LSP server mgmt
lsp_insights: |
  - OpenCode manages LSP internally; no global LSP setting in oh-my-opencode.json
  - LSP configured project-level via pyproject.toml [tool.*] sections
  - Check active LSP: grep logs in ~/.local/share/opencode/log/
  - Pyrefly (Meta's Rust LSP) at /tmp/pyrefly/, faster than pyright
  - Common Python LSPs: pyright, pyrefly, pylsp, ruff
  - Replace pyright→pyrefly via sed: 's/\[tool\.pyright\]/[tool.pyrefly]/'
```

## History

2026-03-15: init
2026-03-15: added LSP config reference, lsp commands, pyrefly research
