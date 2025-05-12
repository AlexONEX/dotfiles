local lint = require("lint")
local utils = require("utils")

lint.linters_by_ft = {
  cpp = { "clangtidy", "cpplint" },
  haskell = { "hlint" },
  lua = { "luacheck" },
  markdown = { "markdownlint", "vale" },
  python = { "ruff", "mypy" },
  rust = { "clippy" },
  sh = { "shellcheck" },
  sql = { "sqlfluff" },
  tex = { "chktex", "lacheck" },
  text = { "proselint", "write_good" },
  toml = {}, -- No built-in TOML linters in nvim-lint
  vim = { "vint" },
  yaml = { "yamllint" },
  gitcommit = { "gitlint" },
  gitignore = {},
  log = {},
  rsync = {},
}

-- Python-specific
lint.linters.ruff = {
  cmd = function()
    local venv = os.getenv("VIRTUAL_ENV")
    if venv then
      if vim.fn.has("win32") == 1 then
        return venv .. "\\Scripts\\ruff.exe"
      else
        return venv .. "/bin/ruff"
      end
    end
    return "ruff"
  end,
  stdin = true,
  args = function()
    local python_info = utils.get_python_info()
    return {
      "--select=E,F,W,I,N,B,RUF",
      "--format=text",
      "--target-version=" .. python_info.version,
    }
  end,
  parser = require("lint.parser").from_pattern(
    "^.*:(%d+):(%d+): (%a%d+) (.+)$",
    { "lnum", "col", "code", "message" },
    {
      ["E"] = vim.diagnostic.severity.ERROR,
      ["F"] = vim.diagnostic.severity.ERROR,
      ["W"] = vim.diagnostic.severity.WARN,
      ["I"] = vim.diagnostic.severity.INFO,
      ["N"] = vim.diagnostic.severity.HINT,
      ["B"] = vim.diagnostic.severity.WARN,
      ["RUF"] = vim.diagnostic.severity.INFO,
    },
    { source = "ruff" }
  ),
}

-- mypy configuration
lint.linters.mypy = {
  cmd = function()
    local venv = os.getenv("VIRTUAL_ENV")
    if venv then
      if vim.fn.has("win32") == 1 then
        return venv .. "\\Scripts\\mypy.exe"
      else
        return venv .. "/bin/mypy"
      end
    end
    return "mypy"
  end,
  stdin = false,
  args = {
    "--show-column-numbers",
    "--no-error-summary",
    "--no-pretty",
    "--disallow-untyped-defs",
  },
  parser = lint.linters.mypy.parser,
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

-- C/C++ linter configuration
if utils.executable("clang-tidy") then
  lint.linters.clangtidy.args = {
    "--checks=*",
    "--warnings-as-errors=*",
  }
end

-- Rust linter configuration
if utils.executable("clippy") then
  lint.linters.clippy.args = {
    "--message-format=json",
    "--",
    "--warn",
    "clippy::all",
  }
end

-- Shell linter configuration
if utils.executable("shellcheck") then
  lint.linters.shellcheck.args = {
    "--format=json",
    "--severity=style",
    "--shell=bash",
    "-",
  }
end

-- LaTeX linter configuration
if utils.executable("chktex") then
  lint.linters.chktex.args = {
    "-q",
    "-v0",
  }
end

-- Set up an autocmd to trigger linting
vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
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
