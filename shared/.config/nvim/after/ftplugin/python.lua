vim.opt_local.wrap = false
vim.opt_local.sidescroll = 5
vim.opt_local.sidescrolloff = 2
vim.opt_local.colorcolumn = "100"
vim.bo.expandtab = true
vim.bo.shiftwidth = 4
vim.bo.softtabstop = 4
vim.bo.tabstop = 4
vim.opt_local.formatoptions:remove({ "o", "r" })

local M = {}
local utils = require("utils")

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
		local row, col = vim.treesitter.get_node_range(node)
		local first_char = vim.api.nvim_buf_get_text(params.buf, row, col, row, col + 1, {})[1]
		if first_char == "f" or first_char == "r" then
			return
		end
		vim.api.nvim_input("<Esc>m'" .. row + 1 .. "gg" .. col + 1 .. "|if<esc>`'la")
	end,
})

function M.run_python()
	local python_info = utils.get_python_info()
	vim.cmd("AsyncRun " .. python_info.exe .. ' -u "%"')
end

function M.format_and_save()
	if utils.executable("ruff") then
		vim.cmd("silent !ruff format %")
		vim.cmd("silent !ruff check --fix %")
		vim.cmd("edit")
		vim.cmd("write")
		vim.notify("Formatted with Ruff", vim.log.levels.INFO)
	else
		vim.notify("Ruff not found. Install with: pip install ruff", vim.log.levels.WARN)
	end
end

function M.lint_python()
	if utils.executable("ruff") then
		vim.cmd("!ruff check %")
	else
		vim.notify("Ruff not found", vim.log.levels.WARN)
	end
end

_G.Ftplugin_Python = M

local opts = { buffer = true, silent = true }
vim.keymap.set("n", "<F9>", function()
	Ftplugin_Python.run_python()
end, opts)
vim.keymap.set("n", "<C-s>", function()
	Ftplugin_Python.format_and_save()
end, opts)
vim.keymap.set("n", "<space>f", function()
	Ftplugin_Python.format_and_save()
end, opts)
vim.keymap.set("n", "<space>l", function()
	Ftplugin_Python.lint_python()
end, opts)
