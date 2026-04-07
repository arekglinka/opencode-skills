```yaml
last_migration: 2026-03-17 Europe/Warsaw
source_branch: feat/vectorbt-integration
target_branch: main2
last_commit_hash: a5c869c
migration_status: staged
conflicts_resolved: false
scope: .opencode/agents/quant-guardian.md (single file)
source_commits: b82d0b4, 4334ecd
```

## Field Descriptions

| Field | Purpose |
|-------|---------|
| last_migration | Timestamp of the most recent migration attempt/completion |
| source_branch | Branch name from which changes are being migrated |
| target_branch | Branch name to which changes are being migrated |
| last_commit_hash | Most recent commit processed (for idempotency/checkpointing) |
| migration_status | Current state: pending, in_progress, completed, failed |
| conflicts_resolved | Boolean indicating whether conflicts were resolved during migration |

## Staleness Check

**Important:** Before starting a new migration, verify that changes don't already exist in the target branch:

1. Compare `last_commit_hash` with target's recent commits
2. Check if source commits are already cherry-picked/merged
3. If stale (changes exist in target), skip or rebase instead
4. Only proceed if `last_commit_hash` not found in target history

This prevents duplicate migrations and preserves git history integrity.
