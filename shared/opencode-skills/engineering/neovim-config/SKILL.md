---
name: neovim-config
description: >
  Neovim config authoring guide for Lua plugins, configs, and dotfiles.
  Covers linting/formatting (StyLua + selene), nvim-best-practices principles,
  style conventions, and plugin structure.
  Use when writing, reviewing, or refactoring any Lua in a Neovim config or plugin.
---

# Neovim Config

## Tooling

Run before merging any Lua change:

```sh
stylua --check .        # formatter (config: .stylua.toml)
selene .                # linter (30+ checks)
lua-language-server     # type checking via LuaCATS annotations
```

## .stylua.toml (this repo)

```toml
column_width = 100
indent_type = "Spaces"
indent_width = 2
quote_style = "AutoPreferDouble"
call_parentheses = "NoSingleTable"
```

## Principles

From nvim-best-practices (upstreamed to `:h lua-plugin`):

- **No forced `setup()`** — plugins work out of the box; separate config from init
- **`<Plug>` mappings** — users define keymaps, not hardcoded bindings
- **Subcommands over pollution** — `:Foo install`, not `:FooInstall` + `:FooPrune`
- **Defer `require()`** — load inside command bodies, not at startup
- **LuaCATS annotations** — type hints; catch bugs in CI with lua-language-server
- **Health checks** — provide `lua/{plugin}/health.lua` for `:checkhealth`

## Style Conventions

- 2-space indent, no tabs
- Single quotes preferred
- 100-column lines
- `snake_case` functions/variables, `PascalCase` classes/modules
- No semicolons
- Trailing commas in multi-line tables (cleaner diffs)
- Comments explain *why*, not *what*

## Plugin Structure

```
plugin-name/
├── lua/
│   └── plugin-name/
│       ├── init.lua      # Entry point, setup function
│       ├── health.lua    # :checkhealth integration
│       └── *.lua         # Module files
├── plugin/
│   └── plugin-name.lua   # Auto-loaded, defines commands/autocommands
├── doc/
│   └── plugin-name.txt   # Vimdoc for :h plugin-name
└── tests/
    └── *_spec.lua        # Busted test files
```
