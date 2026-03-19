# VectorBT API Reference Index

> Full content: `~/wsp/rnd2/vectorbt-reference/01-api-reference.md`

---

## Portfolio Simulation Modes

### from_signals() — Most Common

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `close` | array | **required** | Last price per timestep |
| `entries` | bool array | — | Entry signals |
| `exits` | bool array | — | Exit signals |
| `direction` | Direction | `LongOnly` | `LongOnly`, `ShortOnly`, `Both` |
| `sl_stop` | float | `0.0` | Stop loss percentage |
| `sl_trail` | bool | `False` | Trailing stop loss |
| `tp_stop` | float | `0.0` | Take profit percentage |
| `fees` | float | `0.0` | Percentage of order value |
| `init_cash` | float | `1e6` | Initial capital |
| `cash_sharing` | bool | `False` | Share cash across columns |
| `call_seq` | CallSeqType | `Auto` | Execution order |
| `freq` | str | — | Time frequency |

### from_orders() — Rebalancing

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `size` | float/array | `np.inf` | Order size |
| `size_type` | SizeType | `Amount` | Amount/Value/Percent/TargetPercent |
| `group_by` | bool | `False` | Group columns into single portfolio |

---

## Built-in Indicators

| Indicator | Class | Key Outputs |
|-----------|-------|-------------|
| MA | `vbt.MA` | `.ma` |
| RSI | `vbt.RSI` | `.rsi` |
| MACD | `vbt.MACD` | `.macd`, `.signal`, `.hist` |
| BBANDS | `vbt.BBANDS` | `.middle`, `.upper`, `.lower` |
| ATR | `vbt.ATR` | `.atr` |
| STOCH | `vbt.STOCH` | `.slow_k`, `.slow_d` |

---

## Portfolio Properties

| Property | Returns |
|----------|---------|
| `pf.orders` | Orders container |
| `pf.trades` | Trades container |
| `pf.drawdowns` | Drawdowns (**both recovered AND active**) |
| `pf.value()` | Portfolio value over time |
| `pf.stats()` | Full statistics dashboard |

---

## Statistics Metrics

| Metric | Key | Tag |
|--------|-----|-----|
| Total Return | `total_return` | portfolio |
| Max Drawdown | `max_dd` | portfolio+drawdowns |
| Sharpe Ratio | `sharpe_ratio` | returns |
| Win Rate | `win_rate` | trades |
| Profit Factor | `profit_factor` | trades |

---

**Full Reference**: `~/wsp/rnd2/vectorbt-reference/01-api-reference.md`
