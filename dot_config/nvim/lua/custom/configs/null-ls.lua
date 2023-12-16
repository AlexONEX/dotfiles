local null_ls = require "null-ls"
local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics

local sources = {
  -- Formatters
  formatting.prettier, -- for JavaScript, TypeScript, JSON, HTML, CSS, Dockerfile
  formatting.black, -- for Python
  formatting.clang_format, -- for C/C++
  formatting.stylua, -- for Lua
  formatting.rustfmt, -- for Rust
  formatting.google_java_format, -- for Java
  formatting.sqlfmt, -- for SQL
  formatting.yamlfmt, -- for YAML

  -- Linters
  diagnostics.eslint, -- for JavaScript, TypeScript
  diagnostics.stylelint, -- for CSS
  diagnostics.hadolint, -- for Dockerfile
  diagnostics.yamllint, -- for YAML
  diagnostics.jsonlint, -- for JSON
  diagnostics.shellcheck, -- for Shell
  diagnostics.hadolint, -- for Dockerfile
  diagnostics.ruff, -- for Python
  diagnostics.mypy.with {
    extra_args = { "--show-column-numbers" },
  },

  -- ... otros linters según sea necesario
}

null_ls.setup {
  debug = true,
  sources = sources,
}
