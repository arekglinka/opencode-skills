# queue-operations

## Extended Command Reference

### new

```bash
task new <short_desc>
```

1. Read `.queue/.meta` for next_id (default: 1)
2. Create `.queue/{next_id:03d}_{short_desc}/`
3. Write `desc.md` template
4. Increment `.meta`
5. Output path to created task

### load

```bash
task load <id>
```

1. Find folder matching `NNN_*` where NNN = id
2. Read `desc.md` (required)
3. Read `plan.md` if exists
4. Return combined content for context injection

### plan

```bash
task plan <id>
```

1. Find task folder
2. If no `plan.md`, create from template
3. Return path for editing
4. Update `updated: <dt>` header on save

### ls

```bash
task ls [--all]
```

Output format:
```
001_implement-auth    pending    2024-01-15
002_add-tests         planning   2024-01-16
003_fix-bug           done       2024-01-10 (archived)
```

### rm

```bash
task rm <id> [--force]
```

1. Require `--force` for tasks with plan.md
2. Delete entire folder
3. Do NOT decrement id counter

### done

```bash
task done <id>
```

1. Move `NNN_*` to `.queue/.archive/`
2. Preserve timestamps
3. Update status in desc.md to `done`

## Meta File Format

`.queue/.meta`:
```yaml
next_id: 4
created: 2024-01-15
```

## Error Handling

| Error | Cause | Fix |
|-------|-------|-----|
| `Task not found` | Invalid id | `task ls` to see valid ids |
| `desc.md missing` | Corrupted task | Re-create or rm |
| `Queue not initialized` | No `.queue/` | Run `task new` first |
