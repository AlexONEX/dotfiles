vim.bo.expandtab = true
vim.bo.shiftwidth = 2
vim.bo.softtabstop = 2
vim.bo.tabstop = 2
vim.opt_local.formatoptions:remove({ "o", "r" })

if vim.fn.line("$") > 500 then
	vim.opt_local.syntax = "OFF"
end

local M = {}
local utils = require("utils")

function M.format_and_save()
	local formatters = { "yamlfmt", "prettier" }
	local formatter = ""

	for _, fmt in ipairs(formatters) do
		if utils.executable(fmt) then
			formatter = fmt
			break
		end
	end

	if formatter ~= "" then
		local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
		local content = table.concat(lines, "\n")
		local cmd = formatter == "prettier" and "prettier --parser yaml" or formatter
		local formatted = vim.fn.system(cmd, content)

		if vim.v.shell_error == 0 then
			vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(formatted, "\n"))
			vim.notify("YAML formatted with " .. formatter, vim.log.levels.INFO)
		else
			vim.notify("Error formatting YAML: " .. formatted, vim.log.levels.ERROR)
		end
	else
		vim.notify("No YAML formatter found. Install yamlfmt or prettier", vim.log.levels.WARN)
	end
	vim.cmd("write")
end

_G.Ftplugin_Yaml = M

local opts = { buffer = true, silent = true }
vim.keymap.set("n", "<C-s>", function()
	Ftplugin_Yaml.format_and_save()
end, opts)
vim.keymap.set("n", "<space>f", function()
	Ftplugin_Yaml.format_and_save()
end, opts)
