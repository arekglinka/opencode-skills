# VectorBT Skill Memory

## Version Info

```yaml
last_updated: 2026-03-19
vectorbt_version: 0.28.x
reference_source: ~/wsp/rnd2/vectorbt-reference/
repos_analyzed: 7
```

## Reference Location

Full reference at `~/wsp/rnd2/vectorbt-reference/`:
- `README.md` — Quick navigation
- `01-api-reference.md` — Full API (479 lines)
- `02-best-practices.md` — Optimization (375 lines)
- `03-antipatterns.md` — Mistakes to avoid (407 lines)
- `04-production-examples.md` — 7 repos (411 lines)
- `05-limitations.md` — Known issues (209 lines)
- `06-code-patterns.md` — 10 templates (455 lines)

## Key Metrics

| Metric | Value |
|--------|-------|
| Total reference lines | 2,486 |
| Code templates | 10 |
| Antipatterns documented | 15 |
| Production repos analyzed | 7 |

## Critical Reminders

1. **Always shift signals**: `entries.vbt.fshift(1)`
2. **Use `run_combs()`**: 10-100x faster than loops
3. **Filter drawdowns**: `.drawdowns.recovered`
4. **Bool dtype**: `entries.astype(bool)`
5. **Float32 for memory**: `close.astype(np.float32)`
