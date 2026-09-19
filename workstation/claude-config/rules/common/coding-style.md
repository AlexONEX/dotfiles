# Coding Style

## Immutability (CRITICAL)

ALWAYS create new objects, NEVER mutate existing ones:

```
// Pseudocode
WRONG:  modify(original, field, value) → changes original in-place
CORRECT: update(original, field, value) → returns new copy with change
```

Rationale: Immutable data prevents hidden side effects, makes debugging easier, and enables safe concurrency.

## File Organization

ONE RESPONSIBILITY PER FILE (the real rule):
- The file name honestly describes the one thing it does
- High cohesion, low coupling
- Organize by feature/domain, not by type
- Extract shared helpers to a single location; never re-implement inline

Line count is a SMELL, not a law:
- No hard max. A cohesive 900-line file is fine; a 300-line file doing five things is not.
- Soft tripwire: past ~500 lines, ask "is this still one thing, or two?" — split by responsibility only if it's two. Never split just to hit a number (that adds coupling).

## Error Handling

ALWAYS handle errors comprehensively:
- Handle errors explicitly at every level
- Provide user-friendly error messages in UI-facing code
- Log detailed error context on the server side
- Never silently swallow errors

## Input Validation

ALWAYS validate at system boundaries:
- Validate all user input before processing
- Use schema-based validation where available
- Fail fast with clear error messages
- Never trust external data (API responses, user input, file content)

## Code Quality Checklist

Before marking work complete:
- [ ] Code is readable and well-named
- [ ] Functions are small (<50 lines)
- [ ] Files have one responsibility (name describes it); ~500+ lines → checked for a hidden second responsibility
- [ ] No deep nesting (>4 levels)
- [ ] Proper error handling
- [ ] No hardcoded values (use constants or config)
- [ ] No mutation (immutable patterns used)
