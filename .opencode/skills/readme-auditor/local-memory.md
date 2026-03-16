```yaml
last_updated: 2026-03-15 18:00:00 Europe/Warsaw
commit_hash: HEAD
audit_results:
  README.md:
    total_issues: 16
    categories:
      todo:
        count: 0
        issues: []
      broken-link:
        count: 5
        issues:
          - line: 234
            text: docs/context-based-signal-generation.md
            fix: Removed reference (file doesn't exist)
          - line: 235
            text: implementation-plan-refined/2.5-context-based-signal-generation.md
            fix: Added docs/ prefix
          - line: 449
            text: implementation-plan-refined/
            fix: Added docs/ prefix
          - line: 450
            text: docs/project-status.md
            fix: Removed reference (file doesn't exist)
          - line: 452
            text: docs/foundation-dependency-review.md
            fix: Removed reference (file doesn't exist)
      inconsistency:
        count: 0
        issues:
          - line: 48
            text: Code fence without language identifier
            fix: Added ```text
          - line: 74
            text: Code fence without language identifier
            fix: Already had ```text
      critical-code:
        count: 3
        issues:
          - line: 108
            text: 39 tests
            fix: Updated to 53 tests
          - line: 208
            text: context.symbol
            fix: Changed to context.symbols[0]
          - line: 418
            text: SimpleBacktestEngine
            fix: Changed to BacktestEngine
      duplicate:
        count: 6
        issues:
          - lines: 292-306
            section: Quick Quality Check
            fix: Removed entire section
          - lines: 341, 251
            content: uv pip install -e .
            fix: Kept only in Installation section
          - line: 347
            content: pytest
            fix: Kept only in Testing section
          - lines: 356-368
            content: Backtest commands
            fix: Removed from Quick Reference
          - lines: 358-369 duplicate lines 431-445
            content: Backtest CLI commands
            fix: Kept only in Dataset Management
          - lines: 359 duplicate line 435
            content: python scripts/backtest.py run
            fix: Kept only in Dataset Management
      outdated:
        count: 2
        issues:
          - line: 51
            text: bases/backtest_engine/
            fix: Updated to streamlit_backtest/, added bayesian_optimizer/
          - lines: 314-321
            section: Skills
            fix: Updated to reflect available skills
      missing-reference:
        count: 1
        issues:
          - line: 356
            text: scripts/convert_csv_to_parquet.py
            fix: Removed reference (script doesn't exist)
project_context: |
  README.md validated and all issues fixed.
  Removed 40+ lines of duplicate content.
  Updated architecture diagram to reflect current project structure.
  Updated skills section to show only available skills.
  Fixed critical code issues that would break execution.
  Updated all broken documentation links or removed missing references.
```

## History

2026-03-15: init - created validation rules, audit commands
2026-03-15: refactored to meta-skill pattern, moved rules to references/
2026-03-15: Full README audit applied - fixed 16 issues across 6 categories
2026-03-15: Added detailed Components and Bases sections - tables showing all 10 components and 4 bases with descriptions
2026-03-15: Deduplicated AGENTS.md - removed 224 lines of content already in README.md, kept only project-info skill usage instructions
2026-03-15: Updated all reference docs - backtest-guide.md (BacktestEngine fix), dataset-management.md (removed broken script refs), feature-engineering.md (updated to indicators component), data-fetching.md (verified paths)
2026-03-15: Migrated to Polylith loose theme - restructured components/trading_bot/<name>/ and bases/trading_bot/<name>/, updated all docs to use from trading_bot.<component> imports
