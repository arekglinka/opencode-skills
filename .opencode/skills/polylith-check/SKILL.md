name: polylith-check
description: Validates Polylith architecture compliance for Python projects. Use when checking project structure, adding components/bases, configuring namespace, fixing import paths, or integrating Rust/maturin components.

## Structure

```
project/
├── bases/{namespace}/           # NO __init__.py - PEP 420
│   ├── base_one/
│   └── base_two/
├── components/{namespace}/      # NO __init__.py - PEP 420
│   ├── component_a/
│   ├── foundation/
│   └── rust_component/          # Maturin-backed
│       ├── core.py              # try/except wrapper
│       ├── interface.py
│       └── rust/                # Cargo.toml + pyproject.toml + src/lib.rs
├── projects/{api,cli}/
├── test/{bases,components}/{namespace}/
└── pyproject.toml
```

## PEP 420 (CRITICAL)

| Rule | Wrong | Right |
|------|-------|-------|
| Namespace __init__.py | `bases/{ns}/__init__.py` | **NONE** |
| dev-mode-dirs | `["components/{ns}", ...]` | `["components", "bases", "."]` |

## pyproject.toml

```toml
[tool.uv.workspace]
members = ["projects/*", "components/{ns}/rust_component/rust"]

[tool.hatch.build]
dev-mode-dirs = ["components", "bases", "."]  # Parent dirs for PEP 420

[tool.polylith.bricks]
"bases/{ns}/base_one" = "{ns}/base_one"
"components/{ns}/component_a" = "{ns}/component_a"

[dependency-groups]
dev = ["polylith-cli>=1.43.0"]
```

## Rust Component (Maturin)

### rust/Cargo.toml
```toml
[lib]
crate-type = ["cdylib", "rlib"]
[dependencies]
pyo3 = { version = "0.23", features = ["extension-module"], optional = true }
[features]
python = ["dep:pyo3"]
```

### core.py Pattern
```python
try:
    from rust_component_name import RustConfig, run_rust_function  # pyrefly: ignore[missing-import]
    RUST_AVAILABLE = True
except ImportError:
    RUST_AVAILABLE = False
    RustConfig = None
    def run_rust_function(**kw): raise RuntimeError("Rust unavailable")

def run_backtest(...):
    if not RUST_AVAILABLE: return _python_fallback(...)
    return run_rust_function(config=RustConfig(...), ...)
```

## Validation Rules

| Check | Valid | Invalid |
|-------|-------|---------|
| Namespace __init__.py | **NONE** | `bases/{ns}/__init__.py` |
| dev-mode-dirs | `["components", "bases", "."]` | `["components/{ns}"]` |
| Brick names | `underscore_case` | `hyphen-case` |
| Imports | `from {ns}.component` | `from components.component` |
| Maturin imports | `try/except` fallback | Direct import |

## poly check Symbols

| Symbol | Action |
|--------|--------|
| 🤔 | Expected for maturin (optional, has fallback) |
| ❌ | Must fix |
| ✔ | OK |

## Common Issues

| Issue | Fix |
|-------|-----|
| Namespace __init__.py | DELETE - breaks PEP 420 |
| Constant reinstall | Fix dev-mode-dirs + remove __init__.py |
| ImportError | Check `[tool.polylith.bricks]` mapping |
| Maturin not found | Add to `[tool.uv.workspace].members` |

## Adding Brick

1. Create: `components/{ns}/new_brick/`
2. Add: `"components/{ns}/new_brick" = "{ns}/new_brick"` to bricks
3. Import: `from {ns}.new_brick import ...`

## Commands

```bash
uv run poly check   # Validate | uv run poly info  # Structure | uv run poly sync  # Update bricks
```
