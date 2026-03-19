# VectorBT Antipatterns Index

> Full content: `~/wsp/rnd2/vectorbt-reference/03-antipatterns.md`

---

## Look-Ahead Bias (CRITICAL)

### 1. Using shift(-1) for Exits

```python
# ❌ WRONG: Uses FUTURE data
exits = signals.shift(-1) == 0

# ✅ CORRECT: Shift signals forward
exits = (signals == 0).vbt.fshift(1)
```

### 2. Not Shifting Signals by 1 Tick

```python
# ❌ WRONG: Same-bar execution at signal price
entries = fast_ma.ma_crossed_above(slow_ma)

# ✅ CORRECT: Next-bar execution
entries = fast_ma.ma_crossed_above(slow_ma).vbt.fshift(1)
```

### 3. Global Normalization

```python
# ❌ WRONG: Uses entire dataset statistics
z_score = (df['close'] - df['close'].mean()) / df['close'].std()

# ✅ CORRECT: Expanding window only
z_score = (df['close'] - df['close'].expanding().mean()) / df['close'].expanding().std()
```

---

## Performance Antipatterns

### 4. Manual Grid Search

```python
# ❌ WRONG: 10-100x slower
for fast, slow in itertools.product(windows, windows):
    pf = vbt.Portfolio.from_signals(price, entries, exits)

# ✅ CORRECT: Vectorized
fast_ma, slow_ma = vbt.MA.run_combs(price, window=windows, r=2)
pf = vbt.Portfolio.from_signals(price, 
    fast_ma.ma_crossed_above(slow_ma),
    fast_ma.ma_crossed_below(slow_ma))
```

### 5. Not Using Bool Dtype

```python
# ❌ WRONG: Integer dtype
entries = (fast_ma.ma > slow_ma.ma).astype(int)

# ✅ CORRECT: Bool dtype
entries = (fast_ma.ma > slow_ma.ma).astype(bool)
```

### 6. Plotting on Large Data

```python
# ❌ WRONG: Hangs on millions of candles
pf.plot().show()

# ✅ CORRECT: Plot value only
pf.value().vbt.plot().show()
```

---

## Logic Errors

### 7. Drawdowns Include Active

```python
# ❌ WRONG: Includes unrecovered drawdowns
max_dd = pf.drawdowns.max_drawdown()

# ✅ CORRECT: Filter to recovered only
max_dd = pf.drawdowns.recovered.max_drawdown()
```

### 8. Stop Signals Priority

If both exit signal AND stop loss fire on same bar, **only stop executes**.

### 9. SizeType.Percent Reversal

Cannot reverse position with `size_type='percent'`. Use `'targetpercent'` instead.

---

## Memory Antipatterns

### 10. No Cleanup in Loops

```python
# ✅ CORRECT: Explicit cleanup
for window in windows:
    pf = vbt.Portfolio.from_signals(price, entries, exits)
    results.append(pf.stats())
    del pf
    gc.collect()
```

### 11. pf.value() on Large Data

```python
# ❌ WRONG: OOM on large datasets
value = pf.value()  # Creates 5-10x intermediate arrays

# ✅ CORRECT: Use trades records
trades_df = pf.trades.records_readable
total_pnl = trades_df['pnl'].sum()
```

---

**Full Reference**: `~/wsp/rnd2/vectorbt-reference/03-antipatterns.md`
