# opencode-skills

Agent Skills for OpenCode. Build, maintain, compress.

## Installation

### For Humans

Paste into your LLM agent:

```
Install skills from: https://github.com/arekglinka/opencode-skills
Follow instructions at: docs/guide/installation.md
```

### For LLM Agents

```bash
git clone --depth 1 https://github.com/arekglinka/opencode-skills.git /tmp/opencode-skills && \
mkdir -p ~/.config/opencode/skills && \
cp -r /tmp/opencode-skills/.opencode/skills/<skill-name> ~/.config/opencode/skills/
```

### Quick Install (All Skills)

```bash
git clone --depth 1 https://github.com/arekglinka/opencode-skills.git /tmp/opencode-skills && \
mkdir -p ~/.config/opencode/skills && \
cp -r /tmp/opencode-skills/.opencode/skills/* ~/.config/opencode/skills/ && \
ls ~/.config/opencode/skills/*/SKILL.md
```

### Troubleshooting

| Issue | Fix |
|-------|-----|
| 404 on curl | Wait 1 min (rate limit) or try tarball method |
| Skill not found | Copy `.opencode/skills/<name>/`, not repo root |
| Permission denied | `mkdir -p ~/.config/opencode/skills` |

## Skills

| Skill | Description |
|-------|-------------|
| [meta-skill](./.opencode/skills/meta-skill/SKILL.md) | Creates and maintains Agent Skills |
| [readme-auditor](./.opencode/skills/readme-auditor/SKILL.md) | README validation and updating framework |
| [conventional-commits](./.opencode/skills/conventional-commits/SKILL.md) | Enforces Conventional Commits 1.0.0 |
| [branch-migrator](./.opencode/skills/branch-migrator/SKILL.md) | Migrates git branches with analysis, diagrams, validation |
| [global-config](./.opencode/skills/global-config/SKILL.md) | Manages OpenCode and agent configuration |
| [project-info](./.opencode/skills/project-info/SKILL.md) | Lazy project information extractor |
| [task-queue](./.opencode/skills/task-queue/SKILL.md) | Project-local task queue with plan iteration |
| [vectorbt](./.opencode/skills/vectorbt/SKILL.md) | VectorBT backtesting optimization and antipattern prevention |
| [performance-profiling](./.opencode/skills/performance-profiling/SKILL.md) | Profile and optimize strategy execution speed |
| [polylith-check](./.opencode/skills/polylith-check/SKILL.md) | Validates Polylith architecture compliance |
| [yed-diagrams](./.opencode/skills/yed-diagrams/SKILL.md) | Generate yEd-compatible GraphML diagrams |

## Architecture

| Concept | Description |
|---------|-------------|
| **Meta-skill pattern** | Orchestration in SKILL.md, rules in `references/` — avoids content obsolescence |
| **Intent** | Immutable one-liner per skill. Changes only with user approval |
| **Local Memory** | `local-memory.md` tracks: timestamp, commit, upgrade state, project context |
| **Self-Update** | Detects stale memory → asks permission → respects "block until" |
| **Compression** | Abbreviate, inline, mermaid, pipe-delimit. Target <70 lines |
| **Progressive disclosure** | Metadata → Instructions → Resources loaded on-demand |

## Contributing

1. Follow [Agent Skills specification](https://agentskills.io/specification) for SKILL.md format
2. Apply meta-skill pattern (orchestration + `references/`)
3. Validate: [skills-ref validate](https://github.com/agentskills/agentskills/tree/main/skills-ref) `./skill-name`
4. Test in real project

## License

[MIT](./LICENSE) © 2026 Arkadiusz Glinka

## Refs

- [Agent Skills Spec](https://agentskills.io/specification)
- [OpenCode Skills Docs](https://opencode.ai/docs/skills/)
