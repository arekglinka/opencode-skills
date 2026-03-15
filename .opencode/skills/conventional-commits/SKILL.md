---
name: conventional-commits
description: Enforces Conventional Commits 1.0.0 for git messages. Use when committing, preparing commit messages, or user mentions "commit".
---

Conventional commits enable automated changelogs, semantic versioning, and better history.

## Format

```
<type>[scope]: <description>

[body]

[footers]
```

## Types

| Type | SemVer | Use When |
|------|--------|----------|
| `feat` | MINOR | New feature |
| `fix` | PATCH | Bug fix |
| `docs` | - | Documentation |
| `style` | - | Formatting |
| `refactor` | - | Code restructuring |
| `perf` | - | Performance |
| `test` | - | Tests |
| `build` | - | Build/deps |
| `ci` | - | CI config |
| `chore` | - | Other |
| `revert` | - | Revert commit |

## Rules

**Required**:
- Type + `: ` + description
- Description: lowercase, imperative mood ("add" not "added"), no trailing period

**Optional**:
- Scope: `feat(api):`, `fix(auth):`
- Breaking: `feat!:` or `BREAKING CHANGE:` footer
- Body: WHAT and WHY (not HOW)
- Footers: `Refs:`, `Closes:`, `Reviewed-by:`

## Examples

```
feat: add user authentication
fix(api): handle null response
feat!: remove deprecated endpoint

BREAKING CHANGE: Use /users instead of /user
```

## Workflow

1. `git status` → see changes
2. `git diff` → understand changes
3. Determine type + scope
4. Write description (lowercase, imperative)
5. Add body/footers if needed
6. Validate checklist

## Checklist

- [ ] Type present (feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)
- [ ] Colon + space after type
- [ ] Description lowercase, no period, imperative
- [ ] Scope in parens if used
- [ ] `!` or `BREAKING CHANGE:` for breaking
- [ ] Subject <50 chars, body <72 chars/line

## Mistakes

| Wrong | Correct |
|-------|---------|
| `Add feature` | `feat: add feature` |
| `feat: Add feature` | `feat: add feature` |
| `feat: add feature.` | `feat: add feature` |
| `fix: fixed bug` | `fix: fix bug` |
| `feat: add auth for system` | `feat(auth): add authentication` |
