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

-- Automatically make the current string an f-string when typing `{`.
vim.api.nvim_create_autocmd("InsertCharPre", {
	pattern = { "*.py" },
	group = vim.api.nvim_create_augroup("py-fstring", { clear = true }),
	callback = function(params)
		if vim.v.char ~= "{" then
			return
		end

		local node = vim.treesitter.get_node({})

		if not node then
			return
		end

		if node:type() ~= "string" then
			node = node:parent()
		end

		if not node or node:type() ~= "string" then
			return
		end
		local row, col, _, _ = vim.treesitter.get_node_range(node)
		local first_char = vim.api.nvim_buf_get_text(params.buf, row, col, row, col + 1, {})[1]
		if first_char == "f" or first_char == "r" then
			return
		end

		vim.api.nvim_input("<Esc>m'" .. row + 1 .. "gg" .. col + 1 .. "|if<esc>`'la")
	end,
})

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
