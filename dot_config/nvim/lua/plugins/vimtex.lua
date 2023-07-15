return {
  "lervag/vimtex",
  ft = "tex",
  config = function()
    vim.cmd("call vimtex#init()")
    vim.g.vimtex_view_method = "zathura"
    vim.g.vimtex_compiler_method = "latexmk"
    vim.g.vimtex_quickfix_enabled = 1
    vim.g.vimtex_syntax_enabled = 1
    vim.g.vimtex_quickfix_mode = 0
  end,
}
