local M = {}

-- All LSP servers and their required executables
-- format: { server_name, executable, install_hint }
local servers = {
  { "pyright", "pyright", "npm i -g pyright" },
  { "ruff", "ruff", "pip install ruff" },
  { "lua_ls", "lua-language-server", "brew install lua-language-server / luarocks" },
  { "ltex", "ltex-ls", "brew install ltex-ls / github releases" },
  { "clangd", "clangd", "brew install llvm / apt install clangd" },
  { "vimls", "vim-language-server", "npm i -g vim-language-server" },
  { "bashls", "bash-language-server", "npm i -g bash-language-server" },
  { "yamlls", "yaml-language-server", "npm i -g yaml-language-server" },
  { "hls", "haskell-language-server-wrapper", "ghcup install hls" },
  { "rust_analyzer", "rust-analyzer", "rustup component add rust-analyzer" },
  { "texlab", "texlab", "brew install texlab / github releases" },
  { "terraformls", "terraform-ls", "brew install terraform-ls / github releases" },
  { "ts_ls", "typescript-language-server", "npm i -g typescript typescript-language-server" },
  { "jsonls", "vscode-json-language-server", "npm i -g vscode-langservers-extracted" },
  { "taplo", "taplo", "brew install taplo / cargo install taplo-cli" },
  { "pylsp", "pylsp", "pip install python-lsp-server" },
  { "jdtls", "jdtls", "brew install jdtls / eclipse downloads" },
}

-- Extra tools that servers depend on
local extras = {
  { "terraform", "terraform", "brew install terraform / apt install terraform" },
  { "node", "node", "brew install node / apt install nodejs" },
  { "npm", "npm", "brew install node / apt install npm" },
  { "java", "java", "brew install openjdk / apt install default-jdk" },
  { "rg", "rg", "brew install ripgrep / apt install ripgrep" },
  -- Linters
  { "selene", "selene", "brew install selene / cargo install selene" },
  { "luacheck", "luacheck", "brew install luacheck / luarocks install luacheck" },
  { "shellcheck", "shellcheck", "brew install shellcheck / apt install shellcheck" },
  { "markdownlint", "markdownlint", "npm i -g markdownlint-cli" },
  { "sqlfluff", "sqlfluff", "pip install sqlfluff" },
  { "tflint", "tflint", "brew install tflint / github releases" },
  { "chktex", "chktex", "brew install chktex / apt install chktex" },
  { "lacheck", "lacheck", "brew install chktex (includes lacheck)" },
  { "yamllint", "yamllint", "pip install yamllint / brew install yamllint" },
  -- Formatters
  { "stylua", "stylua", "brew install stylua / cargo install stylua" },
}

function M.check()
  local lines = {}
  local ok_count = 0
  local fail_count = 0

  for _, entry in ipairs(servers) do
    local name, exe, hint = entry[1], entry[2], entry[3]
    if vim.fn.executable(exe) > 0 then
      ok_count = ok_count + 1
    else
      fail_count = fail_count + 1
      table.insert(lines, string.format("  ✗  %-22s  missing — %s", name, hint))
    end
  end

  for _, entry in ipairs(extras) do
    local name, exe, hint = entry[1], entry[2], entry[3]
    if vim.fn.executable(exe) > 0 then
      ok_count = ok_count + 1
    else
      fail_count = fail_count + 1
      table.insert(lines, string.format("  ✗  %-22s  missing — %s", name, hint))
    end
  end

  if fail_count == 0 then
    table.insert(lines, "  ✓ All tools installed")
  end

  table.insert(lines, "")
  table.insert(lines, string.format("=== %d ok, %d missing ===", ok_count, fail_count))

  -- Open in a scratch buffer
  vim.cmd("new")
  local buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.api.nvim_buf_set_name(buf, "LSP Checker")
  vim.api.nvim_win_set_cursor(0, { 1, 0 })
end

return M
