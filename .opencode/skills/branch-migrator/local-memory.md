```yaml
last_migration: 2026-03-15 10:30:00 Europe/Warsaw  # datetime - when last migration started/completed
source_branch: feature/xyz                         # string - branch being migrated from
target_branch: main                                # string - branch being migrated to
last_commit_hash: e0d8be7e3de64eee727ac0913044439cf9948880  # sha - last commit processed
migration_status: pending                          # enum: pending|in_progress|completed|failed
conflicts_resolved: []                             # array - list of sha or issues resolved
```

## Field Descriptions

| Field | Purpose |
|-------|---------|
| last_migration | Timestamp of the most recent migration attempt/completion |
| source_branch | Branch name from which changes are being migrated |
| target_branch | Branch name to which changes are being migrated |
| last_commit_hash | Most recent commit processed (for idempotency/checkpointing) |
| migration_status | Current state: pending, in_progress, completed, failed |
| conflicts_resolved | Array of commit SHAs or issue IDs that had conflicts and were resolved |

## Staleness Check

**Important:** Before starting a new migration, verify that changes don't already exist in the target branch:

1. Compare `last_commit_hash` with target's recent commits
2. Check if source commits are already cherry-picked/merged
3. If stale (changes exist in target), skip or rebase instead
4. Only proceed if `last_commit_hash` not found in target history

This prevents duplicate migrations and preserves git history integrity.
