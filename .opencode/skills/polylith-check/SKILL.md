name: polylith-check
description: Validates Polylith architecture compliance for Python projects. Use when checking project structure, adding components/bases, configuring namespace, fixing import paths, or integrating Rust/maturin components.

## Structure

```
project/
├── bases/
│   └── {namespace}/
│       ├── base_one/
│       └── base_two/
├── components/
│   └── {namespace}/
│       ├── component_a/
│       ├── component_b/
│       ├── foundation/
│       └── rust_component/    # Rust-backed component
│           ├── core.py        # Python wrapper with try/except
│           ├── interface.py
│           ├── __init__.py
│           └── rust/          # Maturin package
│               ├── Cargo.toml
│               ├── pyproject.toml
│               └── src/
│                   └── lib.rs
├── development/
│   └── __init__.py
├── projects/
│   ├── api/
│   │   └── pyproject.toml
│   └── cli/
│       └── pyproject.toml
├── test/
│   ├── bases/{namespace}/
│   └── components/{namespace}/
└── pyproject.toml
```

## pyproject.toml (root)

```toml
[tool.uv.workspace]
members = ["projects/*", "components/{namespace}/rust_component/rust"]

[tool.hatch.build]
dev-mode-dirs = ["components/{namespace}", "bases/{namespace}", "development", "."]

[tool.polylith.bricks]
"bases/{namespace}/base_one" = "{namespace}/base_one"
"components/{namespace}/component_a" = "{namespace}/component_a"
"components/{namespace}/rust_component" = "{namespace}/rust_component"
```

## Rust Component with Maturin

### Directory Structure
```
components/{namespace}/rust_component/
├── __init__.py
├── core.py           # Python wrapper
├── interface.py      # ABC/interface
└── rust/
    ├── Cargo.toml
    ├── pyproject.toml
    └── src/
        └── lib.rs
```

### rust/pyproject.toml
```toml
[build-system]
requires = ["maturin>=1.0,<2.0"]
build-backend = "maturin"

[project]
name = "rust_component_name"
version = "0.1.0"
requires-python = ">=3.8"
```

### rust/Cargo.toml
```toml
[package]
name = "rust-component-name"
version = "0.1.0"
edition = "2021"

[lib]
crate-type = ["cdylib", "rlib"]
name = "rust_component_name"
path = "src/lib.rs"

[dependencies]
pyo3 = { version = "0.23", features = ["extension-module"], optional = true }

[features]
default = []
python = ["dep:pyo3"]
```

### Python Wrapper Pattern (core.py)
```python
try:
    from rust_component_name import (  # pyrefly: ignore[missing-import]
        RustConfig,
        run_rust_function,
    )
    RUST_AVAILABLE = True
except ImportError:
    RUST_AVAILABLE = False
    RustConfig = None  # type: ignore[assignment,misc]

    def run_rust_function(**kwargs):
        raise RuntimeError("Rust component not available")

def run_backtest(...):
    if not RUST_AVAILABLE:
        return _python_fallback(...)
    config = RustConfig(...)
    return run_rust_function(config=config, ...)
```

### Workspace Configuration
Add maturin package to workspace members:
```toml
[tool.uv.workspace]
members = ["projects/*", "components/{namespace}/rust_component/rust"]
```

## poly check Warnings

| Symbol | Meaning | Action |
|--------|---------|--------|
| 🤔 | Info/optional | Review if expected; optional packages OK |
| ❌ | Error | Must fix |
| ✔ | OK | No action |

**Maturin packages show 🤔 warning** - this is expected because:
- They're optional local packages built by maturin
- Code must have try/except fallback
- `# pyrefly: ignore[missing-import]` suppresses type errors

## Validation Rules

| Check | Valid | Invalid |
|-------|-------|---------|
| Namespace dir | `bases/{ns}/`, `components/{ns}/` | `bases/`, `components/` directly |
| Brick names | `underscore_case` | `hyphen-case` |
| Imports | `from {ns}.component` | `from components.component` |
| Test dir | `test/` | `tests/` |
| Bricks format | `"path" = "{ns}/brick"` | Missing mapping |
| Maturin imports | `try/except` with fallback | Direct import without fallback |

## Common Issues

| Issue | Fix |
|-------|-----|
| ImportError | Check namespace wrapper exists |
| Module not found | Verify `[tool.polylith.bricks]` mapping |
| Wrong import path | Use `{namespace}.component` not `components.component` |
| Missing __init__.py | Add to component/base root |
| Maturin not found | Add rust dir to `[tool.uv.workspace].members` |
| poly check 🤔 for rust | Expected if code has try/except fallback |

## Adding New Brick

1. Create: `components/{namespace}/new_brick/`
2. Add to `[tool.polylith.bricks]`: `"components/{namespace}/new_brick" = "{namespace}/new_brick"`
3. Import: `from {namespace}.new_brick import ...`
4. Test: `test/components/{namespace}/new_brick/`

## Adding Rust Component

1. Create: `components/{namespace}/rust_brick/rust/`
2. Add `Cargo.toml` with `pyo3` dependency
3. Add `pyproject.toml` with maturin backend
4. Add to workspace: `members = [..., "components/{namespace}/rust_brick/rust"]`
5. Create Python wrapper with try/except import
6. Build: `cd components/{namespace}/rust_brick/rust && uv run maturin develop --release`

## Commands

```bash
uv run poly check           # Validate workspace
uv run poly info            # Show workspace structure
uv run poly libs            # Show third-party libraries
uv run poly sync            # Update pyproject.toml with missing bricks
```
