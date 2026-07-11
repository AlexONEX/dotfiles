-- Auto-start jdtls (downloads sources in background on first load)
if vim.fn.executable("jdtls") > 0 and vim.lsp.get_clients({ bufnr = 0, name = "jdtls" })[1] == nil then
  vim.lsp.enable("jdtls")
end
