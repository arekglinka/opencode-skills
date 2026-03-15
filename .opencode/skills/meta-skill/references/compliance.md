# compliance

| Check | Rule |
|-------|------|
| dir | `name/SKILL.md`, matches frontmatter |
| name | `^[a-z0-9]+(-[a-z0-9]+)*$`, 1-64c |
| desc | 1-1024c, "what"+"when" |
| body | <500 lines, <70 preferred |
| paths | relative, one level deep |
| compress | [compression.md](compression.md) applied |

**Optional frontmatter**: `license`, `compatibility` (≤500c), `metadata` (map), `allowed-tools` (space-delimited)

**Load order**: metadata (~100t) → body (<5000t) → references (on demand)

**Validate**: `skills-ref validate ./skill-name`
