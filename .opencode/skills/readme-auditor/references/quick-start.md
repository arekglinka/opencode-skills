# README Auditor - Quick Reference

## Usage Examples

### Check a specific README

```bash
# Check for issues
readme-validator.py check README.md

# Check if it's valid JSON
echo $?
```

### Audit all READMEs in project

```bash
# Run from project root
cd /home/ag/wsp/opencode-skills
readme-validator.py audit

# Output shows:
# - READMEs checked
# - Issues found by type
# - Line numbers
# - Total issue count
```

### Common Issues Found

| Issue Type | Example | Suggested Fix |
|-------------|---------|---------------|
| TODO markers | `TODO: add tests` | Create issue or remove |
| Insecure badges | `[![badge](http://...)` | Use HTTPS |
| Empty sections | `## Installation` (no content) | Add or remove heading |
| Broken links | `[link](https://dead.com)` | Update or remove |

## Script Options

| Option | Values | Description |
|---------|---------|-------------|
| `check <path>` | `README.md` | Validate single file |
| `audit` | (cwd) | Check all READMEs recursively |
| `update <path>` | `README.md` | Auto-update (not yet implemented) |

## Output Format

JSON output includes:

```json
{
  "path": "README.md",
  "total_issues": 3,
  "issues": {
    "todo": [{"type": "todo", "line": 42, "text": "TODO: fix me"}],
    "empty-section": [...],
    "insecure-badge": [...]
  }
}
```
