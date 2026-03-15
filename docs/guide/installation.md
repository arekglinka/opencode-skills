# Installation

## For Humans

Paste this into your LLM agent session:

```
Install the meta-skill by following instructions here:
https://raw.githubusercontent.com/arekglinka/opencode-skills/main/docs/guide/installation.md
```

## For LLM Agents

Install the meta-skill for OpenCode. Steps:

### Step 1: Locate Config

```bash
# Global skills directory
SKILLS_DIR="$HOME/.config/opencode/skills"

# Create if not exists
mkdir -p "$SKILLS_DIR"
```

### Step 2: Download Skill

```bash
# Clone or download the skill
cd /tmp
git clone --depth 1 https://github.com/arekglinka/opencode-skills.git
cd opencode-skills
```

### Step 3: Install

```bash
# Copy skill to OpenCode config
cp -r .opencode/skills/meta-skill "$HOME/.config/opencode/skills/"
```

### Step 4: Verify

```bash
ls -la "$HOME/.config/opencode/skills/meta-skill/"
# Should show: SKILL.md, local-memory.md, references/
```

### Step 5: Confirm

Say: "✅ meta-skill installed. It will appear in OpenCode's skill list automatically."

## What Gets Installed

```
~/.config/opencode/skills/meta-skill/
├── SKILL.md              # Main skill file
├── local-memory.md       # Self-tracking state
└── references/
    ├── compliance.md     # Spec checklist
    ├── compression.md    # Compression techniques
    └── local-memory-format.md
```

## Usage

After installation, the skill is auto-discovered by OpenCode. Use:

```
skill(name="meta-skill")
```

Or reference it in prompts when creating/updating skills.
