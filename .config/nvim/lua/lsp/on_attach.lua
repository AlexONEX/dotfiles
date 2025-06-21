return function(client, bufnr)
  -- Notificación opcional para saber que se conectó
  vim.notify("LSP Attached: " .. client.name, vim.log.levels.INFO, { title = "LSP" })

  local map = function(mode, l, r, opts)
    opts = opts or {}
    opts.buffer = bufnr
    opts.noremap = true
    opts.silent = true
    vim.keymap.set(mode, l, r, opts)
  end

  -- Keymaps
  map("n", "gd", vim.lsp.buf.definition, { desc = "LSP: Ir a Definición" })
  map("n", "K", vim.lsp.buf.hover, { desc = "LSP: Mostrar Documentación" })
  map("n", "gi", vim.lsp.buf.implementation, { desc = "LSP: Ir a Implementación" })
  map("n", "<space>rn", vim.lsp.buf.rename, { desc = "LSP: Renombrar" })
  map({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, { desc = "LSP: Acciones de Código" })
  map("n", "gr", vim.lsp.buf.references, { desc = "LSP: Mostrar Referencias" })
end
