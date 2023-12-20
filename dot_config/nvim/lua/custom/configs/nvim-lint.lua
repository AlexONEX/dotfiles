require("lint").linters_by_ft = {
  javascript = { "eslint" },
  typescript = { "eslint" },
  css = { "stylelint" },
  dockerfile = { "hadolint" },
  yaml = { "yamllint" },
  json = { "jsonlint" },
  sh = { "shellcheck" },
  python = { "ruff", "mypy" },
  -- Agrega más linters según sea necesario
}

-- Configura un autocmd para activar el linting
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  callback = function()
    require("lint").try_lint()
  end,
})
