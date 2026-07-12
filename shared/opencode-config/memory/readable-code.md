# Readable Code

Always apply these heuristics when writing or reviewing code.

## Naming

- Be specific: `retval` → `seconds_since_request`
- Encode units/types: `delay_secs`, `unsafe_html`, `num_errors`
- Concrete names: `ServerCanStart()` > `CanListenOnPort()`
- Attach details: `max_threads` > `threads`, `plaintext_password` > `password`
- Scope rule: larger scope = longer name. Loop `i` is fine; class member needs context.

## Comments

- Describe WHY and non-obvious consequences. Code shows WHAT.
- Record thought process: "Tried X, didn't work because Y"
- Mark known issues: TODO, FIXME, HACK, XXX
- Comment constants: Why this value?
- Big picture first, then details.

## Control Flow

- Prefer positive: `if (is_valid)` > `if (!is_invalid)`
- Changing value on left: `if (length >= 10)` > `if (10 <= length)`
- Early returns > deep nesting
- Guard clauses > nested success paths

## Variables

- Eliminate intermediaries that don't add clarity
- Shrink scope: define close to use
- Prefer immutable: write-once is easier to reason about

## Decomposition

- Extract functions for logical chunks, even if called once
- One task per function. "and" in description = split it
- Unrelated subproblems = separate functions
- Interface must be obvious. Unclear usage = redesign

## Quality Checks

- Keep nesting shallow (2–3 levels max), flatten with early returns
- Keep functions focused and concise
- Minimize variable scope, define close to use
- Write obvious code that reads naturally
- Maintain consistent naming and formatting throughout

> Reader matters more than writer. Code is read 10x more than written.
