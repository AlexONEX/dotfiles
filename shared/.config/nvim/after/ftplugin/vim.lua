vim.bo.expandtab = true
vim.bo.shiftwidth = 2
vim.bo.softtabstop = 2
vim.bo.tabstop = 2
vim.opt_local.foldmethod = "marker"
vim.opt_local.foldmarker = "{{{,}}}"
vim.opt_local.formatoptions:remove({ "o", "r" })

local M = {}

function M.format_and_save()
	local clients = vim.lsp.get_clients()
	local has_lsp = false
	for _, client in ipairs(clients) do
		if client.name == "vimls" and client.server_capabilities.documentFormattingProvider then
			has_lsp = true
			break
		end
	end

	local save_cursor = vim.fn.getpos(".")
	if has_lsp then
		vim.lsp.buf.format({
			timeout_ms = 2000,
			filter = function(client)
				return client.name == "vimls"
			end,
			async = false,
		})
	else
		vim.cmd([[silent! normal! gg=G]])
	end
	vim.fn.setpos(".", save_cursor)
	vim.cmd("write")
end

function M.run_vim_script()
	vim.cmd("source %")
	vim.notify("Vim script executed", vim.log.levels.INFO)
end

_G.Ftplugin_Vim = M

local opts = { buffer = true, silent = true }
vim.keymap.set("n", "<F9>", function()
	Ftplugin_Vim.run_vim_script()
end, opts)
vim.keymap.set("n", "<C-s>", function()
	Ftplugin_Vim.format_and_save()
end, opts)
vim.keymap.set("n", "<space>f", function()
	Ftplugin_Vim.format_and_save()
end, opts)
