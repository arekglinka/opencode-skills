# GitHub Integration Reference

## Prerequisites
- `gh` CLI installed and authenticated
- `git` available
- User has provided a valid GitHub repo URL

## Workflow

1. Verify authentication
2. Clone existing repo (user must create it first)
3. Copy generated files into cloned repo
4. Commit and push

## Commands

### Verify GH Auth
```bash
gh auth status
```
Exit code 0 = authenticated. Non-zero = ask user to run `gh auth login`.

### Clone Repository
```bash
git clone <URL> <project_dir>
cd <project_dir>
```

### Add Remote and Push (if cookiecutter already has git init)
```bash
cd <generated_project_dir>
git remote add origin <URL>
git push -u origin main
```

### Commit Generated Files
```bash
git add -A
git commit -m "Initial commit from polylith-generator"
git push -u origin main
```

## Error Handling

| Error | Action |
|-------|--------|
| `gh auth status` fails | Prompt user to run `gh auth login` |
| Remote already exists | Skip `git remote add`, use existing |
| Push rejected (non-fast-forward) | Inform user and suggest pull |
| Push rejected (no upstream) | Use `git push -u origin main` |

## Rules
- NEVER use `git push --force` or `git push -f`
- If push is rejected, inform user — do NOT retry with force
- Confirm with user before pushing to public repos
- Check `gh repo view --json visibility` to determine if public
