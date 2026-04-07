Browser automation via browser-bridge — a WebSocket client connecting to a Chrome Extension on `ws://localhost:3456`. Use when navigating, clicking, evaluating JS, taking screenshots, or extracting page content in an already-running Chromium instance. Replaces Playwright MCP when only browser-bridge extension is available.

Shell out to the bridge-cli tool: `node /home/ag/wsp/browser-bridge/tools/bridge-cli.mjs <action> [args]`

Actions:
- `navigate <url>` — go to URL
- `evaluate <expr>` — run JS in page context
- `click <selector> [index]` — click element (0-based index)
- `getUrl` — get current URL
- `getText <selector>` — get element text content
- `getLinks` — extract all links
- `getImages` — extract all images
- `getHtml <selector>` — get element innerHTML
- `screenshot` — take page screenshot (base64)
- `querySelectorAll <selector> [attr]` — query elements
- `waitForSelector <selector> [timeout-ms]` — wait for element
- `scrollTo <y>` — scroll to Y position

The tool connects to `ws://localhost:3456` by default (env `BRIDGE_WS` overrides).

Usage from bash:
```bash
BRIDGE_WS=ws://localhost:3456 node /home/ag/wsp/browser-bridge/tools/bridge-cli.mjs navigate "http://localhost:5678/#/hero-builder"
BRIDGE_WS=ws://localhost:3456 node /home/ag/wsp/browser-bridge/tools/bridge-cli.mjs evaluate "document.querySelectorAll('.hero-tree-vega').length"
BRIDGE_WS=ws://localhost:3456 node /home/ag/wsp/browser-bridge/tools/bridge-cli.mjs click ".hero-tree-vega rect" 0
BRIDGE_WS=ws://localhost:3456 node /home/ag/wsp/browser-bridge/tools/bridge-cli.mjs getUrl
BRIDGE_WS=ws://localhost:3456 node /home/ag/wsp/browser-bridge/tools/bridge-cli.mjs screenshot
```

For programmatic use (multiple sequential actions), use ESM imports:
```javascript
import { connect, navigate, evaluate, click, screenshot, getUrl, getText } from '/home/ag/wsp/browser-bridge/tools/bridge-cli.mjs';
await connect();
await navigate('http://localhost:5678');
const count = await evaluate("document.querySelectorAll('.node').length");
```

Prerequisites:
- Chromium running with browser-bridge extension installed
- WebSocket server on port 3456 (extension connects to it)
- Node.js 18+
