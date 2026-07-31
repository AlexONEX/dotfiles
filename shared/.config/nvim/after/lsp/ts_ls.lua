return {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = { "typescript", "typescriptreact", "typescript.tsx", "javascript", "javascriptreact" },
  init_options = {
    preferences = {
      includeInlayParameterNameHints = "none",
    },
  },
}
