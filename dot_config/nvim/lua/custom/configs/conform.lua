require("conform").setup {
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "black" },
    c = { "clang_format" },
    cpp = { "clang_format" },
    rust = { "rustfmt" },
    java = { "google_java_format" },
    sql = { "sqlfmt" },
    yaml = { "yamlfmt" },
    javascript = { "prettier" },
    typescript = { "prettier" },
    json = { "prettier" },
    html = { "prettier" },
    css = { "prettier" },
    dockerfile = { "prettier" },
  },
  format_on_save = function(bufnr)
    -- Aquí puedes incluir lógica para deshabilitar el formato en guardado automático
    if vim.b.disable_autoformat or vim.g.disable_autoformat then
      return false
    end
    return { timeout_ms = 500, lsp_fallback = true }
  end,
}

-- Comando para formatear manualmente con soporte de rango
vim.api.nvim_create_user_command("Format", function(args)
  local range = nil
  if args.count ~= -1 then
    local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
    range = {
      start = { args.line1, 0 },
      ["end"] = { args.line2, end_line:len() },
    }
  end
  require("conform").format { async = true, lsp_fallback = true, range = range }
end, { range = true })

-- Mapping para formatear con C-s
vim.api.nvim_set_keymap("n", "<C-s>", '<cmd>lua require("conform").format()<CR>', { noremap = true, silent = true })

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
