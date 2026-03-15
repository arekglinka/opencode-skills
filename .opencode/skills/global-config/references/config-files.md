# Config Files Reference

## Common Locations

| Context | Path | Purpose |
|---------|------|---------|
| OpenCode | `~/.config/opencode/oh-my-opencode.json` | Core cfg |
| VSCode | `.vscode/settings.json` | Workspace stgs |
| Git | `~/.gitconfig` | Git cfg |
| Oh-My-Agent | `~/.config/oh-my-openagent/config.json` | Agent cfg |
| System | `/etc/hosts` | DNS mapping |
| Env | `~/.bashrc`, `~/.zshrc` | Shell env |

## Formats

| Format | Ext | Read | Write |
|--------|-----|------|-------|
| JSON | `.json` | `JSON.parse()` | `JSON.stringify()` |
| YAML | `.yml`, `.yaml` | `yaml.safeLoad()` | `yaml.dump()` |
| TOML | `.toml` | `toml.load()` | `toml.dump()` |
| INI | `.ini`, `.cfg` | `configparser` | `configparser.write()` |

## Docs Sources

| Source | URL | Content |
|--------|-----|---------|
| Agent Skills | `agentskills.io/specification` | Skill schema |
| OpenCode | `opencode.ai/docs` | LSP/agent cfg |
| GitHub | `github.com/.../README.md` | Project cfg |
| VSCode | `code.visualstudio.com/docs` | Settings ref |
| Git | `git-scm.com/docs/git-config` | Git cfg |

## Read/Write Examples

### JSON (JS/TS)
```js
// Read
const cfg = JSON.parse(fs.readFileSync('cfg.json', 'utf8'))
// Write
fs.writeFileSync('cfg.json', JSON.stringify(cfg, null, 2))
```

### YAML (Python)
```py
# Read
cfg = yaml.safe_load(open('cfg.yml'))
# Write
yaml.dump(cfg, open('cfg.yml', 'w'))
```

### TOML (Go)
```go
// Read
cfg, _ := toml.LoadFile("cfg.toml")
// Write
toml.WriteFile("cfg.toml", cfg, nil)
```

## Validation

| Tool | Format | Check |
|------|--------|-------|
| `jsonschema` | JSON | Schema validation |
| `yamllint` | YAML | Syntax check |
| `toml validate` | TOML | Format check |
| `git config --check` | INI | Git cfg valid |

## Backup Strategies

| Method | Cmd | Restore |
|--------|-----|---------|
| Copy | `cp cfg.json cfg.json.bak` | `cp cfg.json.bak cfg.json` |
| Git | `git add cfg.json && git commit` | `git checkout HEAD -- cfg.json` |
| Timestamp | `cp cfg.json cfg.json.$(date +%s)` | `cp cfg.json.<ts> cfg.json` |
| Archive | `tar czf cfgs.tar.gz *.json` | `tar xzf cfgs.tar.gz`

## Security

| Issue | Fix |
|-------|-----|
| Sensitive data | `chmod 600 sensitive.json` |
| Secrets | Use env vars or secret managers |
| Injection | Validate input before parse |
| Malformed cfg | Parse with strict mode
