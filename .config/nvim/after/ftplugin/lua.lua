vim.bo.expandtab = true
vim.bo.shiftwidth = 2
vim.bo.softtabstop = 2
vim.bo.tabstop = 2
vim.opt_local.formatoptions:remove { "o", "r" }

if not _G.format_and_save then
  _G.format_and_save = function()
    vim.cmd("silent !stylua %")
    vim.cmd("edit")
    vim.cmd("write")
  end
end

if not _G.run_lua then
  _G.run_lua = function()
    vim.cmd("luafile %")
  end
end

-- Key mappings
local opts = { buffer = true, silent = true }
vim.keymap.set("n", "<C-s>", _G.format_and_save, opts)
vim.keymap.set("n", "<F9>", _G.run_lua, opts)
vim.keymap.set("n", "<space>f", _G.format_and_save, opts)
