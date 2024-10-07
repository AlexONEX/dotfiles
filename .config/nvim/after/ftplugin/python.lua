-- General config
vim.opt_local.wrap = false
vim.opt_local.sidescroll = 5
vim.opt_local.sidescrolloff = 2
vim.opt_local.colorcolumn = "100"
vim.opt_local.tabstop = 4
vim.opt_local.softtabstop = 4
vim.opt_local.shiftwidth = 4
vim.opt_local.expandtab = true
vim.opt_local.formatoptions:remove({ "o", "r" })

local function run_python()
	vim.cmd('AsyncRun python -u "%"')
end

-- Format con Ruff
local function format_and_save()
	vim.cmd("silent !ruff format %")
	vim.cmd("silent !ruff check --fix %")
	vim.cmd("edit") -- Recarga el archivo
	vim.cmd("write")
end

vim.api.nvim_create_user_command("RunPython", run_python, {})
vim.api.nvim_create_user_command("FormatAndSavePython", format_and_save, {})

vim.api.nvim_buf_set_keymap(0, "n", "<F9>", ":RunPython<CR>", { noremap = true, silent = true })
vim.api.nvim_buf_set_keymap(0, "n", "<C-s>", ":FormatAndSavePython<CR>", { noremap = true, silent = true })
