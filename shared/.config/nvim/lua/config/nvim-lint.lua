local lint = require("lint")

lint.linters_by_ft = {
  cpp = {},
  lua = { "luacheck" },
  markdown = { "markdownlint" },
  sh = { "shellcheck" },
  sql = { "sqlfluff" },
  terraform = { "tflint" },
  tex = { "chktex", "lacheck" },
  text = {},
  toml = {},
  yaml = { "yamllint" },
  gitcommit = {},
  gitignore = {},
  log = {},
  rsync = {},
}

-- Lua linter configuration
lint.linters.luacheck.args = {
  "--no-color",
  "--codes",
  "--no-unused",
  "--no-redefined",
  "--globals",
  "vim",
  "--std",
  "luajit+nvim",
}

-- Shell linter configuration
if vim.fn.executable("shellcheck") > 0 then
  lint.linters.shellcheck.args = {
    "--format=json",
    "--severity=style",
    "--shell=bash",
    "-",
  }
end

-- LaTeX linter configuration
if vim.fn.executable("chktex") > 0 then
  lint.linters.chktex.args = {
    "-q",
    "-v0",
  }
end

-- Set up an autocmd to trigger linting
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  callback = function()
    -- Get filetype
    local ft = vim.bo.filetype
    -- Only lint if we have linters defined for this filetype
    if lint.linters_by_ft[ft] and #lint.linters_by_ft[ft] > 0 then
      require("lint").try_lint()
    end
  end,
})

-- Keymaps for manual linting
vim.keymap.set("n", "<leader>ll", function()
  require("lint").try_lint()
end, { desc = "Lint current file" })

-- Keymaps to disable/enable linting temporarily
vim.keymap.set("n", "<leader>ld", function()
  -- Store current linters
  vim.g.linters_backup = vim.deepcopy(lint.linters_by_ft)
  lint.linters_by_ft = {}
  print("Linting disabled")
end, { desc = "Disable linting" })

vim.keymap.set("n", "<leader>le", function()
  -- Restore linters
  if vim.g.linters_backup then
    lint.linters_by_ft = vim.deepcopy(vim.g.linters_backup)
    print("Linting enabled")
  end
end, { desc = "Enable linting" })

-- Agregar keymap para mostrar diagnósticos flotantes manualmente
vim.keymap.set("n", "<leader>lf", function()
  vim.diagnostic.open_float { scope = "line" }
end, { desc = "Show diagnostics in float window" })
