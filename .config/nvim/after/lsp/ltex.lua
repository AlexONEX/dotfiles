local lsp_utils = require("lsp_utils")

return {
  capabilities = lsp_utils.get_default_capabilities(),
  filetypes = { "text", "plaintex", "tex", "markdown" },
  settings = {
    ltex = {
      language = "en",
    },
  },
  flags = { debounce_text_changes = 300 },
}
