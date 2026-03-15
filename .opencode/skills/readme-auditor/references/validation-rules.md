# README Validation Rules

## Common Issues

| Issue | Pattern | Fix |
|-------|---------|-----|
| Broken links | `\[.*\]\(http.*\)` not reachable | Remove or fix |
| TODO markers | `TODO:`, `FIXME:`, `XXX:` | Resolve or add issue link |
| Outdated versions | `v1.2.3` when current is `v2.0+` | Update |
| Dead code blocks | ```bash with `pip install old-package` | Update to current |
| Missing badges | No `[!badge]` at top | Add CI/coverage badges |
| Wrong repo links | `https://github.com/old-name` | Update to new org/name |
| Inconsistent install | npm vs pip vs cargo | Match project lang |
| Empty sections | `## Installation` with no content | Add or remove |

## Link Validation

Check links in order:

1. **External links** (http/https) - HEAD request, check 200/404
2. **Relative links** (`./path`, `../path`) - Verify path exists
3. **Anchors** (`#section`) - Verify heading exists
4. **Code blocks** - Check commands work
5. **Badges** - Verify shields.io URLs work

## Section Requirements

| Section | Required? | Checks |
|---------|------------|--------|
| Installation | Yes | Commands work, deps correct |
| Usage | Yes | Examples runnable, syntax valid |
| Contributing | Yes | Guidelines present |
| License | Yes | Badge matches LICENSE file |
| Changelog | Optional | Recent entries present |

## Auto-Update Rules

When `update` mode is `auto`:

1. **Update badges** - Fetch latest CI status
2. **Update version** - Read from package.json/Cargo.toml/pyproject.toml
3. **Update install commands** - Match latest package manager patterns
4. **Remove deprecated sections** - Check for "Legacy" or "Old method"
5. **Add recent changes** - Read last 3 commits, add to changelog

## Consistency Checks

| Check | Rule |
|-------|------|
| Code fence language | `bash` for shell, `python` for Python, match file type |
| Command prefixes | Use `$ ` for shell, `uv run` or `pip install ` for Python |
| File references | Linked files must exist (e.g., `@path/to/config`) |
| Badge formats | `[![name](url)]` standard format |
| Heading levels | `#` title, `##` major sections, no skipped levels |
