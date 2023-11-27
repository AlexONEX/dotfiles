require("lint").linters_by_ft = {
  markdown = { "vale" },
  python = { "flake8", "pylint" }, -- Python linters
  yaml = { "yamllint" }, -- YAML linter
  tex = { "chktex" }, -- LaTeX linter
  c = { "clangtidy" }, -- C linter
  cpp = { "clangtidy" }, -- C++ linter
  javascript = { "eslint" }, -- JavaScript linter
  typescript = { "eslint" }, -- TypeScript linter
  scala = { "scalafmt" }, -- Scala linter
  -- Add other file types and their respective linters here
}

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*",
  callback = function()
    require("lint").try_lint()
  end,
})
