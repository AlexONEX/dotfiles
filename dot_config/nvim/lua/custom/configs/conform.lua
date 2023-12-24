-- Import the conform module
local conform = require "conform"

-- Original configuration with filetypes sorted alphabetically
conform.setup {
  formatters_by_ft = {
    bash = { "beautysh" },
    c = { "clang_format" },
    cpp = { "clang_format" },
    css = { { "prettierd", "prettier" } },
    dockerfile = { "prettier" },
    erb = { "htmlbeautifier" },
    graphql = { { "prettierd", "prettier" } },
    html = { "htmlbeautifier" },
    java = { "google-java-format" },
    javascript = { { "prettierd", "prettier" } },
    javascriptreact = { { "prettierd", "prettier" } },
    json = { { "prettierd", "prettier" } },
    kotlin = { "ktlint" },
    lua = { "stylua" },
    markdown = { { "prettierd", "prettier" } },
    proto = { "buf" },
    python = { "black" },
    ruby = { "standardrb" },
    rust = { "rustfmt" },
    scss = { { "prettierd", "prettier" } },
    svelte = { { "prettierd", "prettier" } },
    toml = { "taplo" },
    typescript = { { "prettierd", "prettier" } },
    typescriptreact = { { "prettierd", "prettier" } },
    yaml = { "yamlfix" },
  },
  format_on_save = function()
    if vim.b.disable_autoformat or vim.g.disable_autoformat then
      return false
    end
    return { timeout_ms = 500, lsp_fallback = true }
  end,
}

-- Mapping para formatear con C-s

vim.api.nvim_set_keymap(
  "n",
  "<C-s>",
  '<cmd>lua require("conform").format(); vim.cmd("w")<CR>',
  { noremap = true, silent = true }
)

-- Comandos para habilitar/deshabilitar el formato en guardado automático
vim.api.nvim_create_user_command("FormatDisable", function(args)
  if args.bang then
    vim.b.disable_autoformat = true
  else
    vim.g.disable_autoformat = true
  end
end, { bang = true })

vim.api.nvim_create_user_command("FormatEnable", function()
  vim.b.disable_autoformat = false
  vim.g.disable_autoformat = false
end, {})

vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function(args)
    require("conform").format { bufnr = args.buf }
  end,
})
