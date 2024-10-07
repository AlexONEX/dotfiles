-- File: /home/mars/.config/nvim/after/ftplugin/lua.lua

-- General configuration
vim.opt_local.expandtab = true
vim.opt_local.shiftwidth = 2
vim.opt_local.softtabstop = 2
vim.opt_local.tabstop = 2
vim.opt_local.formatoptions:remove({ "o", "r" })

-- Function to format with StyLua and save
function _G.format_and_save()
	vim.cmd("silent !stylua %")
	vim.cmd("edit") -- Reload the file
	vim.cmd("write")
end

-- Function to run the Lua script
function _G.run_lua()
	vim.cmd("luafile %")
end

-- Key mappings
vim.api.nvim_buf_set_keymap(0, "n", "<C-s>", ":lua _G.format_and_save()<CR>", { noremap = true, silent = true })
vim.api.nvim_buf_set_keymap(0, "n", "<F9>", ":lua _G.run_lua()<CR>", { noremap = true, silent = true })
