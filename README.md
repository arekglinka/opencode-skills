# opencode-skills

Agent Skills for OpenCode. Build, maintain, compress.

## Installation

### For Humans

Paste into your LLM agent:

```
Install the meta-skill by following instructions here:
https://raw.githubusercontent.com/arekglinka/opencode-skills/main/docs/guide/installation.md
```

### For LLM Agents

```bash
curl -s https://raw.githubusercontent.com/arekglinka/opencode-skills/main/docs/guide/installation.md
```

### Quick Install (One-Liner)

```bash
mkdir -p ~/.config/opencode/skills && \
curl -fsSL https://github.com/arekglinka/opencode-skills/archive/refs/heads/main.tar.gz | \
tar xz -C /tmp && \
cp -r /tmp/opencode-skills-main/.opencode/skills/meta-skill ~/.config/opencode/skills/ && \
ls ~/.config/opencode/skills/meta-skill/SKILL.md
```

### Troubleshooting

| Issue | Fix |
|-------|-----|
| 404 on curl | Wait 1 min (rate limit) or try tarball method |
| Skill not found | Copy `.opencode/skills/meta-skill/`, not repo root |
| Permission denied | `mkdir -p ~/.config/opencode/skills` |

## Skills

| Skill | Description |
|-------|-------------|
| [meta-skill](./.opencode/skills/meta-skill/SKILL.md) | Creates + maintains Agent Skills, applies compression |

## Architecture

| Concept | Description |
|---------|-------------|
| **Intent** | Immutable one-liner. Changes only with user approval |
| **Local Memory** | `local-memory.md` tracks: timestamp, commit, upgrade state, project context |
| **Self-Update** | Detects stale memory → asks permission → respects "block until" |
| **Compression** | Abbreviate, inline, mermaid, pipe-delimit. Target <70 lines |

## Contributing

1. Follow skill structure
2. Apply compression rules
3. Validate: `skills-ref validate ./skill-name`
4. Test in real project

## Refs

- [Agent Skills](https://agentskills.io/specification)
- [OpenCode Skills](https://opencode.ai/docs/skills/)
