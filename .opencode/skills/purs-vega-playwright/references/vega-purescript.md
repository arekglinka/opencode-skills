# Vega–PureScript FFI Patterns

## Architecture

```
PureScript → FFI (.js) → vega-embed → Vega View
                ↑
           data (JSON)   click callback
```

PureScript builds the spec as `Json`, passes node/edge arrays as JSON, receives clicks via `Ref` + poll loop.

## FFI Signature Pattern

```purescript
-- VegaEmbed.purs
foreign import embedView
  :: String                           -- element ID
  -> Json                             -- Vega spec
  -> Json                             -- nodes data (JSON array)
  -> Json                             -- edges data (JSON array)
  -> (String -> Effect Unit)          -- click callback
  -> Effect Unit
```

JS receives this as 5 nested functions → final thunk:

```js
export const embedView = function(elId) {
  return function(spec) { return function(nodes) { return function(edges) {
    return function(onClick) { return function() { /* ... */ }; };
  }; }; };
};
```

## Critical: Effect Thunks

`String -> Effect Unit` in PS = `(String) => () => void` in JS.

```js
// WRONG — returns the thunk without executing it
onClick(skillId);

// RIGHT — invoke the thunk to execute the Effect
onClick(skillId)();
```

Symptom: callback appears to run (no errors, returns a function) but state never changes.

## Critical: Maybe FFI

| PS | JS |
|----|-----|
| `Nothing` | `null` |
| `Just x` | `x` (bare value) |
| `{tag:"Just", value:x}` | **CRASH** — pattern match on null |

Never use `{tag, value}` encoding in FFI. PureScript's runtime expects bare values for `Just`.

## Critical: Vega Encode Properties

Vega encode properties accept objects, not bare values:

| Wrong | Right |
|-------|-------|
| `"width": 38.0` | `"width": {"value": 38}` |
| `"cursor": "pointer"` | `"cursor": {"value": "pointer"}` |

PureScript helper:
```purescript
val :: Json -> Json
val j = obj [ Tuple "value" j ]
```

Symptom: marks render at default size (rects 0×0, images 256×256) despite encode having correct values.

## Data Insertion Pattern

Spec declares empty named datasets; data inserted separately:

```purescript
-- Spec (no inline data)
Tuple "data" $ fromArray
  [ obj [ Tuple "name" $ str "nodes" ]
  , obj [ Tuple "name" $ str "edges" ]
  ]
```

```js
// FFI: insert after embed
view.insert("nodes", nodesJson).run();
view.insert("edges", edgesJson).run();
```

Avoids `view.data()` and `view.change()` which have compatibility issues across Vega versions.

## Click Handling: Direct DOM over view.addEventListener

`view.addEventListener("click", handler)` fires via Vega's scenegraph hit testing system. In SVG renderer, this often doesn't propagate DOM clicks properly.

**Use direct DOM listener instead:**

```js
var svg = el.querySelector("svg");
if (svg) {
  svg.addEventListener("click", function(event) {
    var target = event.target;
    while (target && target !== svg) {
      var item = target.__data__;
      if (item && item.datum && item.datum.id) {
        onClick(item.datum.id)();
        return;
      }
      target = target.parentElement;
    }
  });
}
```

`__data__` structure: `target.__data__.datum.id` (datum is nested under the Vega scene item).

## vega-embed Import

```js
// CORRECT (default export)
import vegaEmbed from "vega-embed";

// WRONG (named export)
import { embed } from "vega-embed";
```

## View Lifecycle

```js
// Re-embed on state change (full replace)
if (_views[elementId]) {
  _views[elementId].finalize();  // clean up previous
  delete _views[elementId];
}
vegaEmbed("#" + elementId, spec, opts).then(function(result) {
  _views[elementId] = result;
  // ... insert data, add listeners
});
```

`finalize()` prevents DOM leaks. Store view reference for cleanup on next embed.

## Poll Loop (avoid Halogen.Subscription)

```purescript
clickRef <- H.liftEffect $ Ref.new (Nothing :: Maybe String)
let pollClicks = do
  H.liftAff $ delay (Milliseconds 80.0)
  mClick <- H.liftEffect $ Ref.read clickRef
  case mClick of
    Just skillId -> do
      H.liftEffect $ Ref.write Nothing clickRef
      handleAction (ToggleSkill skillId)
    Nothing -> pure unit
  pollClicks
void $ H.fork pollClicks
```

`Halogen.Subscription` import causes `InfiniteType` compiler bug in some PS 0.15 + Halogen v7 combinations.
