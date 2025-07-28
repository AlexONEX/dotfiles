local lspconfig = require("lspconfig")

local capabilities = require("cmp_nvim_lsp").default_capabilities()

local servers = {
  "bashls",
  "clangd",
  "hls",
  "ltex",
  "lua_ls",
  "delance-langserver",
  "ruff",
  "rust_analyzer",
  "texlab",
  "vimls",
  "yamlls",
}

for _, server_name in ipairs(servers) do
  lspconfig[server_name].setup {
    capabilities = capabilities,
  }
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("Mars_LspConfig", { clear = true }),
  callback = function(event)
    local bufnr = event.buf
    local map = function(mode, l, r, desc)
      vim.keymap.set(mode, l, r, { buffer = bufnr, silent = true, desc = "LSP: " .. desc })
    end

    map("n", "gd", vim.lsp.buf.definition, "Ir a Definición")
    map("n", "gD", vim.lsp.buf.declaration, "Ir a Declaración")
    map("n", "gr", vim.lsp.buf.references, "Mostrar Referencias")
    map("n", "gi", vim.lsp.buf.implementation, "Ir a Implementación")
    map("n", "K", vim.lsp.buf.hover, "Mostrar Documentación (Hover)")
    map({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, "Acciones de Código")
    map("n", "<space>rn", vim.lsp.buf.rename, "Renombrar Símbolo")
  end,
})

vim.diagnostic.config {
  underline = true,
  virtual_text = { prefix = "●" },
  signs = true,
  update_in_insert = false,
  severity_sort = true,
}

local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Diagnóstico Anterior" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Siguiente Diagnóstico" })
