-- This file is automatically loaded by plugins.core
vim.g.mapleader = " "

vim.opt.softtabstop = 0

--set font
vim.o.guifont = "CaskaydiaCove Nerd Font Mono:h9"

--set tab to 4 spaces
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true

vim.opt.autowrite = true
vim.opt.clipboard = "unnamedplus"
vim.opt.conceallevel = 3

vim.opt.relativenumber = true
vim.opt.guicursor = ""
vim.opt.hidden = true
vim.opt.nu = true

vim.opt.smartindent = false
vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.config/nvim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 75
vim.opt.colorcolumn = "75"

vim.g.python3_host_prog = "/usr/bin/python3"
vim.opt.spelllang = "es"

if vim.g.neovide then
  vim.g.neovide_scale_factor = 1.0
  vim.g.neovide_hide_mouse_when_typing = true
  vim.g.neovide_cursor_animation_length = 0
end
