# local-memory-format

## Full Schema

```yaml
managed_skills:
  <skill-name>:
    source_repo: <git-url | local-path>
    source_branch: <branch-name | tag | sha>
    commit_hash: <sha>
    last_updated: <iso8601>
meta:
  last_updated: <iso8601>
  commit_hash: <sha>
  upgrade_permission: allowed|blocked
  upgrade_blocked_until: <iso8601 | null>
  project_context: <str>
```

## Fields

| Field | Required | Description |
|-------|----------|-------------|
| source_repo | yes | Git remote URL or local path |
| source_branch | yes | Branch/tag/SHA to track |
| commit_hash | yes | SHA at last update |
| last_updated | yes | Timestamp of last sync |
| project_context | no | Freeform project notes (preserved across migrations) |

## Example

```yaml
managed_skills:
  branch-migrator:
    source_repo: https://github.com/arekglinka/opencode-skills
    source_branch: main
    commit_hash: a1b2c3d
    last_updated: 2026-04-07T10:30:00
meta:
  last_updated: 2026-04-07T10:30:00
  commit_hash: a1b2c3d
  upgrade_permission: allowed
  upgrade_blocked_until: null
  project_context: opencode-skills repo
```

## Duration Parsing

| Input | Result |
|-------|--------|
| `1d` | tomorrow |
| `1w` | +7 days |
| `1m` | +30 days |
| `never` | 2099-12-31 |

## Status Detection

```bash
# Check if skill is stale (tries branch, then tag)
git ls-remote $source_repo refs/heads/$source_branch
git ls-remote $source_repo refs/tags/$source_branch
# Compare to local commit_hash
```

| Remote HEAD | Local SHA | Status |
|-------------|-----------|--------|
| == | commit_hash | synced |
| ≠ | commit_hash | behind |
| - | - | untracked |
