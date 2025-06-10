vim.opt_local.formatoptions:remove({ "o", "r" })
vim.opt_local.expandtab = true
vim.opt_local.shiftwidth = 2
vim.opt_local.softtabstop = 2

if vim.fn.line("$") > 500 then
	vim.opt_local.syntax = "OFF"
end

local M = {}

function M.format_and_save()
	local formatters = { "yamlfmt", "prettier --parser yaml" }
	local formatter = ""
	for _, fmt in ipairs(formatters) do
		if vim.fn.executable(vim.split(fmt, " ")[1]) == 1 then
			formatter = fmt
			break
		end
	end
	if formatter ~= "" then
		local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
		local content = table.concat(lines, "\n")
		local formatted = vim.fn.system(formatter, content)
		if vim.v.shell_error == 0 then
			vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(formatted, "\n"))
			print("YAML formatted successfully.")
		else
			print("Error formatting YAML: " .. formatted)
		end
	else
		print("No YAML formatter found. Install yamlfmt or prettier for formatting.")
	end
	vim.cmd("write")
end

_G.Ftplugin_Yaml = M

vim.keymap.set("n", "<C-s>", ":lua Ftplugin_Yaml.format_and_save()<CR>", { noremap = true, silent = true, buffer = 0 })
