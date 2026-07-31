return {
  cmd = { "vim-language-server", "--stdio" },
  filetypes = { "vim" },
  flags = {
    debounce_text_changes = 500,
  },
}
