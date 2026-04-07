# Playwright + Snap Chromium Setup

## Problem

Playwright MCP and CLI expect Chrome at `/opt/google/chrome/chrome`. On Ubuntu with snap Chromium, it's at `/snap/bin/chromium`.

## Launch

```js
import { chromium } from 'playwright';

const browser = await chromium.launch({
  executablePath: '/snap/bin/chromium',
  headless: true
});
const context = await browser.newContext();
const page = await context.newPage();
```

**Always** use `browser.newContext()` + page from context. Avoid `browser.newPage()` directly — `setCacheEnabled` only exists on `BrowserContext`, not `Page`.

## CLI Screenshots

```bash
PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH=/snap/bin/chromium \
  npx playwright screenshot --browser chromium \
  http://localhost:8080/page.png
```

## Programmatic Testing

### Check Page State

```js
const result = await page.evaluate(() => ({
  svgCount: document.querySelectorAll('svg').length,
  imageCount: document.querySelectorAll('svg image').length,
  points: document.body.innerText.match(/(\d+) \/ 24 skills/)?.[1],
  selects: Array.from(document.querySelectorAll('select')).map(s => ({
    optionCount: s.options.length
  })),
}));
```

### Click SVG Elements

Images in Vega SVG have no `x`/`y` attrs — positioned via parent `<g>` transforms. Use `getBoundingClientRect()`:

```js
const img = await page.evaluate(() => {
  const img = document.querySelector('#my-svg image');
  const r = img.getBoundingClientRect();
  return { cx: r.left + r.width/2, cy: r.top + r.height/2 };
});
await page.mouse.click(img.cx, img.cy);
```

### Check Click Handler Fires

```js
// Option A: console.log in FFI, check via page.on('console')
page.on('console', msg => consoleMsgs.push(msg.text()));

// Option B: Direct DOM event + promise
await page.evaluate(() => new Promise(resolve => {
  const el = document.querySelector('svg');
  el.addEventListener('click', e => resolve({ tag: e.target.tagName }));
  // ... dispatch event
}));
```

## Cache Issues

### Bundle caching

Headless Chromium caches aggressively. Even with `?nocache=` URL params, the old bundle may persist.

**Fixes:**
1. Use a **fresh port** for each test run (`python3 -m http.server $((8100 + RANDOM))`)
2. Restart Playwright with new `browser.newContext()` each test
3. Verify bundle contents: `grep "expected-string" dev/bundle.js`

### spago build copies .js files

PureScript compiler copies `src/Util/Foo.js` → `output/Util.Foo/foreign.js` during `spago build`. If you edit a `.js` FFI file, you **must** run `spago build` before `npm run build:js` (esbuild bundles from `output/`).

```bash
npx spago build && npm run build:js  # both required after .js changes
```

## Common Errors

| Error | Cause | Fix |
|-------|-------|-----|
| `Chromium distribution 'chrome' is not found at /opt/google/chrome/chrome` | Wrong path | `executablePath: '/snap/bin/chromium'` |
| `mouse.click: Protocol error (Input.dispatchMouseEvent): Invalid parameters` | `NaN` coordinates | Use `getBoundingClientRect()` not `getBBox()` |
| `page2.setCacheEnabled is not a function` | Called on Page not Context | Use `browser.newContext()` |
| `Playwright not found` | Global install only | Import from global: `/home/ag/.local/share/fnm/node-versions/v22.22.1/installation/lib/node_modules/playwright/index.mjs` |
| Points stay 0 after click | Effect thunk not invoked | `onClick(id)()` not `onClick(id)` |
| Vega encode values ignored | Bare numbers/strings | Use `{"value": …}` wrapper |
| Images 256×256, rects 0×0 | Encode props ignored | Same as above |
| `view.addEventListener` never fires | Vega v6 SVG hit testing broken | Use direct DOM click + `__data__` walk |

## Image-less Testing

This model doesn't support image input. To verify visuals:

1. `page.evaluate()` — extract positions, sizes, colors, text as data
2. `PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH` CLI screenshots — save to `/tmp/` and tell user to view
3. Delegate to human — "open http://localhost:8080 in your browser and check"
