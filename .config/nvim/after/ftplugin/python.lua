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

-- Make these functions local to avoid global variable warning
local function run_python()
	vim.cmd('AsyncRun python -u "%"')
end

local function format_and_save()
	vim.cmd("silent !ruff format %")
	vim.cmd("silent !ruff check --fix %")
	vim.cmd("edit")
	vim.cmd("write")
end

vim.api.nvim_create_user_command("RunPython", run_python, {})
vim.api.nvim_create_user_command("FormatAndSavePython", format_and_save, {})

-- Use vim.keymap.set instead of vim.api.nvim_buf_set_keymap
vim.keymap.set("n", "<F9>", ":RunPython<CR>", { noremap = true, silent = true, buffer = 0 })
vim.keymap.set("n", "<C-s>", ":FormatAndSavePython<CR>", { noremap = true, silent = true, buffer = 0 })
