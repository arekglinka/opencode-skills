# LSP Configuration Reference

## OpenCode LSP Architecture

OpenCode manages LSP servers internally. **Global LSP server selection is NOT configurable** via oh-my-opencode.json.

### Key Locations

| Purpose | Path | Description |
|---------|--------|-------------|
| Active LSP logs | `~/.local/share/opencode/log/*.log` | Shows which LSP servers are running |
| Project database | `~/.local/share/opencode/opencode.db` | Stores project metadata (no LSP settings) |
| Pyrefly install | `/tmp/pyrefly/` | Auto-generated Pyrefly LSP files |
| Schema | `~/.cache/opencode/node_modules/oh-my-opencode/dist/oh-my-opencode.schema.json` | Defines available config options (no LSP fields) |

### LSP Configuration Methods

#### Project-Level (Recommended)

LSP servers are configured **per-project** via config files:

| Tool | Config File | Section |
|------|-------------|----------|
| Pyright | `pyproject.toml` | `[tool.pyright]` |
| Pyrefly | `pyproject.toml` | `[tool.pyrefly]` |
| Pylsp | `pyproject.toml` | `[tool.pylsp]` |
| Ruff | `pyproject.toml` | `[tool.ruff]` |

**Example**:
```toml
[tool.pyrefly]
search_path = ["src"]
project_includes = ["."]
python_platform = "linux"

[tool.pyrefly.errors]
bad-assignment = false
```

#### Check Current Active LSP

```bash
# Search logs for active LSP servers
grep -i "enabled LSP servers" ~/.local/share/opencode/log/*.log

# Check Python LSP specifically
grep "serverID=py" ~/.local/share/opencode/log/*.log
```

#### Common Python LSP Servers

| Server | ID | Config | Notes |
|---------|------|--------|-------|
| Pyright | `pyright` | Microsoft's Python type checker |
| Pyrefly | `pyrefly` | Meta's Rust-based LSP (1.85M LOC/s) |
| Pylsp | `pylsp` | PyLS with multiple backends |
| Ruff | `ruff` | Fast linter with LSP support |

## Quick Commands

### List Project LSP Configs
```bash
find ~/wsp -name "pyproject.toml" -exec grep -l "\[tool\.py" {} \;
```

### Replace Pyright with Pyrefly
```bash
# Find all pyproject.toml with pyright
find ~/wsp -name "pyproject.toml" -exec grep -l "\[tool\.pyright\]" {} \;

# Replace in file
sed -i 's/\[tool\.pyright\]/[tool.pyrefly]/' pyproject.toml
```

### Verify LSP is Running
```bash
# Check logs for server activity
tail -f ~/.local/share/opencode/log/*.log | grep "service=lsp"
```

## Notes

- OpenCode does NOT expose LSP server selection in `oh-my-opencode.json`
- LSP configuration is **project-level only**, not global
- Some projects may have multiple `[tool.*]` sections
- Restart OpenCode after changing project configs
