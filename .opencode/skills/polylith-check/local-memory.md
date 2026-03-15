last_updated: 2026-03-15
commit_hash: 359ff197ae09ca3b1fbe327c8f53289f52f47559
upgrade_permission: allowed
upgrade_blocked_until: null
project_context: |
  trading-bot project uses Polylith with:
  - Namespace: trading_bot
  - Rust component: components/trading_bot/backtest_engine/rust/ (maturin)
  - Workspace members: projects/* + rust component
  - 🤔 warnings for maturin packages are expected (optional, try/except fallback)
  - Brick paths use forward slash: "components/trading_bot/brick" = "trading_bot/brick"
