vim.opt_local.formatoptions:remove({ "o", "r" })

local function format_and_save()
	vim.cmd("silent !taplo format %")
	vim.cmd("edit")
	vim.cmd("write")
end

vim.api.nvim_create_user_command("FormatAndSaveToml", format_and_save, {})

vim.api.nvim_buf_set_keymap(0, "n", "<C-s>", ":FormatAndSaveToml<CR>", { noremap = true, silent = true })
