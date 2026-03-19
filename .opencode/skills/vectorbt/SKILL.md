---
name: vectorbt
description: VectorBT backtesting optimization, antipattern prevention, and production patterns. Use when building/testing trading strategies with vectorbt.
license: MIT
compatibility: opencode
---

Spec: [vectorbt.dev](https://vectorbt.dev/) | [GitHub](https://github.com/polakowo/vectorbt)

## When to Use

- Building trading strategies with VectorBT
- Optimizing backtest performance (10-100x speedup possible)
- Avoiding look-ahead bias and overfitting
- Setting up stop loss / take profit
- Multi-asset portfolio rebalancing
- Parameter sweeps and grid search

## Quick Reference

| File | Path | Content |
|------|------|---------|
| Full Reference | `./vectorbt-reference/` | Complete 6-file guide |
| API Docs | `./vectorbt-reference/01-api-reference.md` | Portfolio, indicators, signals |
| Best Practices | `./vectorbt-reference/02-best-practices.md` | Memory, caching, broadcasting |
| Antipatterns | `./vectorbt-reference/03-antipatterns.md` | Look-ahead, overfitting |
| Templates | `./vectorbt-reference/06-code-patterns.md` | 10 copy-paste patterns |

---

## Core Optimization

### #1 Rule: Use Vectorized Parameter Sweeping

```python
# ❌ SLOW (10-100x) - Manual loop
for fast, slow in itertools.product(windows, windows):
    pf = vbt.Portfolio.from_signals(close, entries, exits)

# ✅ FAST - Vectorized
fast_ma, slow_ma = vbt.MA.run_combs(price, window=windows, r=2)
entries = fast_ma.ma_crossed_above(slow_ma)
pf = vbt.Portfolio.from_signals(price, entries, exits)
```

---

## Simulation Modes

| Mode | Use When | Key Params |
|------|----------|------------|
| `from_holding()` | Benchmark | `init_cash` |
| `from_signals()` | Entry/exit strategies | `entries`, `exits`, `sl_stop`, `tp_stop` |
| `from_orders()` | Rebalancing, target weights | `size`, `size_type="targetpercent"` |
| `from_order_func()` | Custom logic | `order_func_nb` (numba) |
| `from_random_signals()` | Monte Carlo | `n`, `seed` |

---

## Critical Antipatterns

| Antipattern | Fix |
|-------------|-----|
| `exits = signals.shift(-1)` | `.vbt.fshift(1)` — shift forward |
| Not shifting by 1 tick | Always shift: `entries.vbt.fshift(1)` |
| Manual grid search | Use `MA.run_combs()` + broadcasting |
| `pf.drawdowns` unfiltered | Use `.drawdowns.recovered` |
| `pf.plot()` on large data | Plot `pf.value().vbt.plot()` |
| Global normalization | Use `expanding()` window |

---

## Multi-Asset Pattern

```python
pf = vbt.Portfolio.from_signals(
    price, entries, exits,
    cash_sharing=True,    # Share capital
    call_seq="auto",      # Optimize order
    group_by=True,        # Single portfolio
    fees=0.001
)
```

---

## Memory Optimization

```python
close = data['close'].astype(np.float32)  # 50% reduction
entries = entries.astype(bool)             # Critical for correctness
del portfolio; gc.collect()                # Explicit cleanup
```

---

## Stop Loss / Take Profit

```python
pf = vbt.Portfolio.from_signals(
    close, entries, exits,
    sl_stop=0.05,         # 5% stop loss
    sl_trail=True,        # Trailing
    tp_stop=0.10,         # 10% take profit
    open=ohlcv['Open'],   # Required for stops
    high=ohlcv['High'],
    low=ohlcv['Low']
)
```

---

## Refs

- [api-reference](references/api-reference.md) — Full parameter tables
- [antipatterns](references/antipatterns.md) — 15 mistakes with fixes
- [code-patterns](references/code-patterns.md) — 10 templates
