local lint = require("lint")

lint.linters_by_ft = {
  cpp = {},
  lua = { "selene", "luacheck" },
  markdown = { "markdownlint" },
  sh = { "shellcheck" },
  sql = { "sqlfluff" },
  terraform = { "tflint" },
  tex = { "chktex", "lacheck" },
  text = {},
  toml = {},
  java = { "pmd" },
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

-- Toggle linting on/off (clears visible lint diagnostics when disabling)
vim.keymap.set("n", "<leader>lt", function()
  if vim.g.lint_disabled then
    lint.linters_by_ft = vim.g.linters_backup or lint.linters_by_ft
    vim.g.lint_disabled = false
    require("lint").try_lint()
    vim.notify("Linting enabled", vim.log.levels.INFO)
  else
    vim.g.linters_backup = vim.deepcopy(lint.linters_by_ft)
    lint.linters_by_ft = {}
    vim.g.lint_disabled = true
    -- nvim-lint uses namespaces named "nvim-lint-<linter>"; reset only those
    for ns_id, ns in pairs(vim.diagnostic.get_namespaces()) do
      if ns.name and ns.name:find("nvim-lint", 1, true) then
        vim.diagnostic.reset(ns_id)
      end
    end
    vim.notify("Linting disabled", vim.log.levels.WARN)
  end
end, { desc = "Toggle linting" })

-- Agregar keymap para mostrar diagnósticos flotantes manualmente
vim.keymap.set("n", "<leader>ce", function()
  vim.diagnostic.open_float { scope = "line" }
end, { desc = "Show diagnostics in float window" })
