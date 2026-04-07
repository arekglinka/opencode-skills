# Handoff File Format

## First Line (required)

```
# HANDOFF <unix_timestamp>
```

Unix timestamp = `int(time.time())`. Used for sorting and cleanup.

## Sections

All section headers use UPPERCASE with dashes (no #):

```
USER REQUESTS (AS-IS)
---------------------
- Verbatim user requests (NOT paraphrased)

GOAL
----
One sentence: what should be done next.

WORK COMPLETED
--------------
- First person ("I did X, I told you Y")
- Include file paths when relevant
- Note key decisions and discoveries

CURRENT STATE
-------------
- Codebase/task state
- Build/test status
- Environment or config state

PENDING TASKS
-------------
- Planned but incomplete tasks
- Next logical steps
- Blockers or issues
- Current todo state from session

KEY FILES
---------
- path/to/file — brief role (max 10 files)
- Prioritize by importance

IMPORTANT DECISIONS
-------------------
- Technical decisions + why
- Trade-offs considered
- Patterns/conventions established

EXPLICIT CONSTRAINTS
--------------------
- Verbatim constraints only (user or AGENTS.md)
- If none: write "None"

CONTEXT FOR CONTINUATION
------------------------
- What next session needs to know
- Warnings or gotchas
- References to docs/specs
```

## Rules

- No markdown `#` headers within sections (use the format above)
- No bold/italic/code fences within content
- Workspace-relative paths for files
- USER REQUESTS: verbatim only, do not paraphrase
- CONSTRAINTS: verbatim only, do not invent
- Focused content only — skip implementation details unless critical
- Max 200 lines for typical sessions

## Cleanup Logic

```python
import glob, os

files = sorted(glob.glob(".handoff/*.md"))
if len(files) > 2:
    for f in files[:-2]:  # keep newest 2
        os.remove(f)
```

## Continuation Instructions (append after handoff)

```
---

TO CONTINUE IN A NEW SESSION:

1. Press 'n' in OpenCode TUI to open a new session
2. Paste the HANDOFF CONTEXT above as your first message
3. Add: "Continue from the handoff context above. [Your next task]"
```
