last_updated: 2026-03-16
commit_hash: 44773afaf14c061c27e8cea19a6a3cc211cc2533
upgrade_permission: allowed
upgrade_blocked_until: null
project_context: |
  trading-bot project uses Polylith with:
  - Namespace: trading_bot
  - NO __init__.py in namespace dirs (PEP 420)
  - dev-mode-dirs: ["components", "bases", "."] (parent dirs)
  - Rust component: components/trading_bot/backtest_engine/rust/ (maturin)
  - Workspace members: projects/* + rust component
  - polylith-cli in [dependency-groups].dev
  - 🤔 warnings for maturin packages are expected (optional, try/except fallback)
