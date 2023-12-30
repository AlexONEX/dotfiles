-- Import the lint module
local lint = require "lint"

-- Define linters by file type
lint.linters_by_ft = {
  css = { "stylelint" },
  dockerfile = { "hadolint" },
  html = { "htmlbeautifier" },
  java = { "google-java-format" },
  javascript = { "eslint" },
  javascriptreact = { "eslint" },
  json = { "jsonlint" },
  kotlin = { "ktlint" },
  markdown = { "markdownlint" },
  proto = { "buf" },
  python = { "ruff", "mypy" },
  rust = { "rustfmt" },
  sh = { "shellcheck" },
  scss = { "stylelint" },
  terraform = { "tflint" },
  tf = { "tflint" },
  toml = { "taplo" },
  typescript = { "eslint" },
  typescriptreact = { "eslint" },
  yaml = { "yamllint" },
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
