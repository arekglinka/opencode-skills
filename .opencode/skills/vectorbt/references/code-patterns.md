# VectorBT Code Patterns Index

> Full content: `~/wsp/rnd2/vectorbt-reference/06-code-patterns.md`

---

## Pattern 1: Basic SMA Crossover

```python
import vectorbt as vbt

price = vbt.YFData.download("BTC-USD").get("Close")
fast_ma = vbt.MA.run(price, 10)
slow_ma = vbt.MA.run(price, 50)
entries = fast_ma.ma_crossed_above(slow_ma).vbt.fshift(1)
exits = fast_ma.ma_crossed_below(slow_ma).vbt.fshift(1)
pf = vbt.Portfolio.from_signals(price, entries, exits, init_cash=100, fees=0.001)
```

---

## Pattern 2: Multi-Asset Parameter Sweep

```python
import numpy as np

symbols = ["BTC-USD", "ETH-USD", "LTC-USD"]
price = vbt.YFData.download(symbols, missing_index='drop').get('Close')

windows = np.arange(2, 101)
fast_ma, slow_ma = vbt.MA.run_combs(price, window=windows, r=2)
pf = vbt.Portfolio.from_signals(price, 
    fast_ma.ma_crossed_above(slow_ma),
    fast_ma.ma_crossed_below(slow_ma),
    size=np.inf, fees=0.001)

# Access specific combo
pf[(10, 50, 'ETH-USD')].stats()
```

---

## Pattern 3: Stop Loss + Take Profit

```python
data = vbt.YFData.download("BTC-USD")
ohlcv = data.get()

pf = vbt.Portfolio.from_signals(
    ohlcv['Close'], entries, exits,
    sl_stop=0.05, sl_trail=True, tp_stop=0.10,
    open=ohlcv['Open'], high=ohlcv['High'], low=ohlcv['Low'],
    fees=0.001, freq='1D'
)
```

---

## Pattern 4: Periodic Rebalancing

```python
# Target weights with NaN = no rebalance
target_weights = pd.DataFrame(np.nan, index=price.index, columns=price.columns)
target_weights.iloc[::20] = [0.4, 0.3, 0.3]  # Rebalance every 20 days

pf = vbt.Portfolio.from_orders(
    close=price, size=target_weights, size_type="targetpercent",
    cash_sharing=True, call_seq="auto", group_by=True
)
```

---

## Pattern 5: Monte Carlo

```python
pf = vbt.Portfolio.from_random_signals(price, n=1000, init_cash=100, seed=42)
sharpe_dist = pf.sharpe_ratio()
print(f"95th percentile: {sharpe_dist.quantile(0.95):.3f}")
```

---

## Pattern 6: Custom Indicator

```python
from numba import njit

@njit
def zscore_apply_nb(close, window):
    n = len(close)
    result = np.empty(n)
    result[:window-1] = np.nan
    for i in range(window-1, n):
        window_data = close[i-window+1:i+1]
        mean, std = np.mean(window_data), np.std(window_data)
        result[i] = (close[i] - mean) / std if std > 0 else 0
    return result

ZScore = vbt.IndicatorFactory(
    input_names=['close'], param_names=['window'], output_names=['zscore']
).from_apply_func(zscore_apply_nb)
```

---

## Pattern 7: Cash Sharing Multi-Asset

```python
pf = vbt.Portfolio.from_signals(
    price, entries, exits,
    init_cash=10000, cash_sharing=True, call_seq="auto", group_by=True,
    fees=0.001, freq='1D'
)
```

---

## Pattern 8: Factor-Based Strategy

```python
momentum = price.pct_change(63)
factor_rank = momentum.rolling(252, min_periods=1).rank(pct=True)
entries = factor_rank >= 0.8
exits = factor_rank < 0.8

pf = vbt.Portfolio.from_signals(
    price, entries.astype(bool), exits.astype(bool),
    init_cash=10000, cash_sharing=True, group_by=True
)
```

---

## Pattern 9: ML Signals

```python
from sklearn.ensemble import RandomForestClassifier

# Features: returns, volatility, momentum, RSI
X = pd.DataFrame({'returns': returns, 'volatility': volatility, 'momentum': momentum, 'rsi': rsi})
y = (price.pct_change().shift(-1) > 0)

model = RandomForestClassifier(n_estimators=100, max_depth=5)
model.fit(X_train, y_train)
predictions = pd.Series(model.predict(X_test), index=X_test.index)

entries = (predictions == 1) & (predictions.shift(1) == 0)
exits = (predictions == 0) & (predictions.shift(1) == 1)
```

---

## Pattern 10: Persistence

```python
# Save
pf.save('my_portfolio.pkl')

# Load
pf_loaded = vbt.Portfolio.load('my_portfolio.pkl')

# Export trades
pf.trades.records_readable.to_csv('trades.csv', index=False)
```

---

**Full Reference**: `~/wsp/rnd2/vectorbt-reference/06-code-patterns.md`
