# Installation

## For Humans

Paste into your LLM agent:

```
Install the meta-skill by following instructions here:
https://raw.githubusercontent.com/arekglinka/opencode-skills/main/docs/guide/installation.md
```

## For LLM Agents

### Prerequisites

- OpenCode installed
- Git or curl available

### Method 1: Git Clone (Recommended)

```bash
# 1. Create target directory
mkdir -p "$HOME/.config/opencode/skills"

# 2. Clone to temp location
cd /tmp
git clone --depth 1 https://github.com/arekglinka/opencode-skills.git
cd opencode-skills

# 3. Copy skill (note: skill is inside .opencode/skills/)
cp -r .opencode/skills/meta-skill "$HOME/.config/opencode/skills/"

# 4. Verify
ls "$HOME/.config/opencode/skills/meta-skill/SKILL.md"
```

### Method 2: Direct Download (No Git)

```bash
# 1. Create target
mkdir -p "$HOME/.config/opencode/skills/meta-skill/references"

# 2. Download files
REPO="https://raw.githubusercontent.com/arekglinka/opencode-skills/main/.opencode/skills/meta-skill"

curl -fsSL "$REPO/SKILL.md" -o "$HOME/.config/opencode/skills/meta-skill/SKILL.md"
curl -fsSL "$REPO/local-memory.md" -o "$HOME/.config/opencode/skills/meta-skill/local-memory.md"
curl -fsSL "$REPO/references/compliance.md" -o "$HOME/.config/opencode/skills/meta-skill/references/compliance.md"
curl -fsSL "$REPO/references/compression.md" -o "$HOME/.config/opencode/skills/meta-skill/references/compression.md"
curl -fsSL "$REPO/references/local-memory-format.md" -o "$HOME/.config/opencode/skills/meta-skill/references/local-memory-format.md"

# 3. Verify
ls "$HOME/.config/opencode/skills/meta-skill/SKILL.md"
```

### Method 3: Tarball

```bash
# 1. Download and extract
curl -fsSL https://github.com/arekglinka/opencode-skills/archive/refs/heads/main.tar.gz | tar xz -C /tmp

# 2. Create target and copy
mkdir -p "$HOME/.config/opencode/skills"
cp -r /tmp/opencode-skills-main/.opencode/skills/meta-skill "$HOME/.config/opencode/skills/"

# 3. Verify
ls "$HOME/.config/opencode/skills/meta-skill/SKILL.md"
```

### Verification

```bash
# Check all files exist
ls -la "$HOME/.config/opencode/skills/meta-skill/"
# Expected: SKILL.md, local-memory.md, references/

ls "$HOME/.config/opencode/skills/meta-skill/references/"
# Expected: compliance.md, compression.md, local-memory-format.md
```

### Success Message

Say: "✅ meta-skill installed to `~/.config/opencode/sills/meta-skill/`. Restart OpenCode or start a new session to use it."

## Troubleshooting

### 404 Errors

If `curl` or `git clone` returns 404:

1. **Check URL manually**: Open https://github.com/arekglinka/opencode-skills in browser
2. **If accessible in browser but not CLI**: May be rate-limited. Wait 1 minute, retry.
3. **If not accessible**: Repo may be private or URL incorrect. Verify with user.

### Clone Succeeds But Skill Not Found

The skill is nested inside `.opencode/skills/`:

```
opencode-skills/           # repo root
└── .opencode/
    └── skills/
        └── meta-skill/    # ← THIS is what you copy
            ├── SKILL.md
            ├── local-memory.md
            └── references/
```

Wrong: `cp -r opencode-skills "$HOME/.config/opencode/skills/"`
Right: `cp -r opencode-skills/.opencode/skills/meta-skill "$HOME/.config/opencode/skills/"`

### Permission Denied

```bash
# Ensure directory exists
mkdir -p "$HOME/.config/opencode/skills"

# Check permissions
ls -la "$HOME/.config/opencode/"
```

## Installed Structure

```
~/.config/opencode/skills/meta-skill/
├── SKILL.md              # Main skill (86 lines)
├── local-memory.md       # Self-tracking state
└── references/
    ├── compliance.md     # Spec checklist
    ├── compression.md    # Compression techniques
    └── local-memory-format.md
```

## Usage

```python
skill(name="meta-skill")
```
