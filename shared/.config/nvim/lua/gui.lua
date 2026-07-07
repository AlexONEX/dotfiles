-- GUI settings (migrated from ginit.vim)
-- Loaded conditionally for GUI-capable Neovim frontends

-- Fix key mapping issues for GUI
vim.keymap.set("i", "<S-Insert>", "<C-R>+", { silent = true })
vim.keymap.set("c", "<S-Insert>", "<C-R>+")
vim.keymap.set("n", "<C-6>", "<C-^>", { silent = true })

-- nvim-qt
if vim.g.GuiLoaded then
  vim.cmd("GuiTabline 0")
  vim.cmd("GuiPopupmenu 0")
  vim.cmd("GuiLinespace 2")
  vim.cmd("GuiFont! Hack NF:h10:l")
end

-- neovide
if vim.g.neovide then
  vim.o.guifont = "Hack NF:h10"
  vim.g.neovide_transparency = 1.0
  vim.g.neovide_cursor_animation_length = 0.1
  vim.g.neovide_cursor_trail_size = 0.3
  vim.g.neovide_cursor_vfx_mode = ""
  vim.g.neovide_cursor_vfx_particle_density = 10.0
  vim.g.neovide_cursor_vfx_opacity = 150.0
end
