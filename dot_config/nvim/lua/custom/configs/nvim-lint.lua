-- Import the lint module
local lint = require "lint"

-- Define linters by file type
lint.linters_by_ft = {
  css = { "stylelint" },
  dockerfile = { "hadolint" },
  graphql = { "graphql-lsp" },
  html = { "htmlbeautifier" },
  java = { "google-java-format" },
  javascript = { "eslint" },
  javascriptreact = { "eslint" },
  json = { "jsonlint" },
  kotlin = { "ktlint" },
  markdown = { "markdownlint" },
  proto = { "buf" },
  python = { "ruff", "mypy" },
  ruby = { "standardrb" },
  rust = { "rustfmt" },
  scss = { "stylelint" },
  sh = { "shellcheck" },
  svelte = { "svelte-check" },
  terraform = { "tflint" },
  toml = { "taplo" },
  typescript = { "eslint" },
  typescriptreact = { "eslint" },
  yaml = { "yamllint" },
  -- Add more linters as needed
}

-- Create an autocmd to trigger linting on BufWritePost
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  callback = function()
    lint.try_lint()
  end,
})

-- Define a key mapping to trigger linting for the current file
vim.keymap.set("n", "<leader>ll", function()
  lint.try_lint()
end, { desc = "Trigger linting for current file" })
