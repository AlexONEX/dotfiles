-- General configuration
vim.opt_local.expandtab = true
vim.opt_local.shiftwidth = 2
vim.opt_local.softtabstop = 2
vim.opt_local.tabstop = 2
vim.opt_local.formatoptions:remove({ "o", "r" })

-- Function to format with shfmt and save
function _G.format_and_save_bash()
	vim.cmd("silent !shfmt -i 2 -ci -w %")
	vim.cmd("edit") -- Reload the file
	vim.cmd("write")
end

-- Function to run the Bash script
function _G.run_bash()
	vim.cmd("!bash %")
end

-- Key mappings
vim.api.nvim_buf_set_keymap(0, "n", "<C-s>", ":lua _G.format_and_save_bash()<CR>", { noremap = true, silent = true })
vim.api.nvim_buf_set_keymap(0, "n", "<F9>", ":lua _G.run_bash()<CR>", { noremap = true, silent = true })
