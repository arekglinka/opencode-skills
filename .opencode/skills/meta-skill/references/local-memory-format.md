# memory-format

| Field | Type | Desc |
|-------|------|------|
| `last_updated` | dt | refresh time |
| `commit_hash` | sha | at update |
| `upgrade_permission` | `allowed\|blocked` | auto? |
| `upgrade_blocked_until` | `date\|null` | re-ask when |
| `project_context` | str | notes |

**Stale**: `HEAD ≠ commit_hash`

**Durations**: 1d→tomorrow | 1w→+7d | 1m→+30d | never→2099-12-31
