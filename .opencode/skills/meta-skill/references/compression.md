# compression

Apply to all skills. Revisit on each update.

## Techniques

| Method | Before | After |
|--------|--------|-------|
| Abbreviate | `characters` | `c` |
| Abbreviate | `datetime` | `dt` |
| Abbreviate | `string` | `str` |
| Abbreviate | `description` | `desc` |
| Drop header | `## Validation\n\n| Check |` | `| Check |` |
| Inline | `Must be 1-64 chars` | `1-64c` |
| Single-line | `a\nb\nc` | `a \| b \| c` |
| Pipe map | `opt1: val1\nopt2: val2` | `opt1→val1 \| opt2→val2` |
| Merge | Two sections with 1 rule each | One section with 2 rules |

## Mermaid

Use when:
- Flow with 3+ branches
- Decision tree
- State machine

Keep node labels ≤2 words.

## Progressive Disclosure

| Content | Location |
|---------|----------|
| Core logic | `SKILL.md` body |
| Checklists | `references/` |
| Examples | `references/` |
| Schemas | `references/` |

## Review Checklist

- [ ] Headers removed where not structural?
- [ ] Tables used instead of prose?
- [ ] Abbreviations consistent?
- [ ] Mappings pipe-delimited?
- [ ] Extended content moved to `references/`?
- [ ] Mermaid used for flows?
