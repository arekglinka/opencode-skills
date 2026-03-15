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

Fetch and follow:

```bash
curl -s https://raw.githubusercontent.com/arekglinka/opencode-skills/main/docs/guide/installation.md
```

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

### Memory Placement

| Context | Store |
|---------|-------|
| Project-specific | `local-memory.md` |
| Skill-intrinsic | `SKILL.md` |

## Contributing

1. Follow skill structure
2. Apply compression rules
3. Validate: `skills-ref validate ./skill-name`
4. Test in real project

## Refs

- [Agent Skills](https://agentskills.io/specification)
- [OpenCode Skills](https://opencode.ai/docs/skills/)
