last_updated: 2026-03-18
commit_hash: 16a5a74
upgrade_permission: allowed
upgrade_blocked_until: null
project_context: |
  trading-bot project uses Polylith with:
  - Namespace: trading_bot
  - NO __init__.py in namespace dirs (PEP 420)
  - dev-mode-dirs: ["components", "bases", "."] (parent dirs)
  - Rust component: components/trading_bot/backtest_engine/rust/ (maturin)
  - uv sync auto-builds Rust extension (no build script needed)
  - [tool.uv.sources] resolves backtest_engine_rust to local path
  - [tool.uv] cache-keys in rust/pyproject.toml triggers rebuild on .rs changes
  - [tool.maturin] features = ["python"] (NOT "pyo3/extension-module")
  - 🤔 warnings for maturin packages are expected (optional, try/except fallback)
