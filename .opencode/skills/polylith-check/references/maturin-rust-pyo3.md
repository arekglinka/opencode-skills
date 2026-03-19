# Maturin + uv + Polylith: Rust/PyO3 Extension Build Reference

## TL;DR

`uv sync` auto-builds Rust extensions via maturin. No build script needed.

## Required Files

```
components/{ns}/rust_component/
├── interface.py
├── core.py                  # try/except import wrapper
└── rust/                    # ← maturin-managed
    ├── Cargo.toml
    ├── Cargo.lock
    ├── pyproject.toml        # ← build config
    └── src/lib.rs           # PyO3 bindings
```

## pyproject.toml (rust/)

```toml
[build-system]
requires = ["maturin>=1.0,<2.0"]
build-backend = "maturin"

[project]
name = "rust_component_name"
version = "0.1.0"
requires-python = ">=3.13"

[tool.maturin]
module-name = "rust_component_name"
features = ["python"]        # ← Cargo feature, NOT "pyo3/extension-module"
locked = true

[tool.uv]
cache-keys = [              # ← triggers rebuild on .rs changes
    { file = "Cargo.toml" },
    { file = "src/**/*.rs" },
]
```

## pyproject.toml (root)

```toml
[project]
dependencies = [
    "rust_component_name",  # ← uv resolves via [tool.uv.sources]
    # ...
]

[tool.uv.sources]
rust_component_name = { path = "components/{ns}/rust_component/rust" }
```

## Cargo.toml

```toml
[lib]
name = "rust_component_name"
crate-type = ["cdylib", "rlib"]

[dependencies]
pyo3 = { version = "0.23", features = ["extension-module"], optional = true }

[features]
python = ["dep:pyo3"]

[profile.release]
opt-level = 3
lto = true
# strip = true              # ← do NOT strip, breaks symbol exports
```

## lib.rs (PyO3 bindings)

```rust
#[cfg(feature = "python")]
#[pymodule]
fn rust_component_name(_py: Python, m: &Bound<'_, PyModule>) -> PyResult<()> {
    m.add_class::<SomeClass>()?;
    m.add_function(wrap_pyfunction!(some_func, m)?)?;
    Ok(())
}
```

## How It Works

```
uv sync
  └─→ sees backtest_engine_rust in dependencies
      └─→ resolves to local path via [tool.uv.sources]
          └─→ finds build-backend = "maturin" in rust/pyproject.toml
              └─→ cargo build --release --features python
                  └─→ installs .so into venv
```

## Pitfalls

| Problem | Cause | Fix |
|---------|-------|-----|
| `PyInit_` not found | `features = ["pyo3/extension-module"]` | Use `features = ["python"]` |
| No rebuild on .rs edit | Missing `[tool.uv] cache-keys` | Add to rust/pyproject.toml |
| Stale .so from old cargo build | `build-rust.sh` copied manually | Delete stale .so, rely on maturin only |
| Import via `__init__.py` fails | Nested package conflict | maturin handles `__init__.py` — no manual `__init__.py` needed |
| `strip = true` breaks exports | Symbols removed from .so | Remove `strip = true` from `[profile.release]` |
| `locked = true` + missing dep | `Cargo.lock` stale | Run `cargo update` in rust/ dir |
| `module-name` mismatch | Name doesn't match `[lib] name` in Cargo.toml | Must match exactly |
