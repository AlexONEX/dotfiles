vim.opt_local.expandtab = true
vim.opt_local.shiftwidth = 2
vim.opt_local.softtabstop = 2
vim.opt_local.tabstop = 2
vim.opt_local.foldmethod = "marker"
vim.opt_local.foldmarker = "{{{,}}}"
vim.opt_local.formatoptions:remove({ "o", "r" })

local M = {}

function M.format_and_save()
	local clients = vim.lsp.get_clients()
	local has_lsp = false
	for _, client in ipairs(clients) do
		if client.name == "lua_ls" and client.server_capabilities.documentFormattingProvider then
			has_lsp = true
			break
		end
	end
	local save_cursor = vim.fn.getpos(".")
	if has_lsp then
		vim.lsp.buf.format({
			timeout_ms = 2000,
			filter = function(client)
				return client.name == "lua_ls"
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
end

_G.Ftplugin_Vim = M

vim.keymap.set("n", "<F9>", ":lua Ftplugin_Vim.run_vim_script()<CR>", { noremap = true, silent = true, buffer = 0 })
vim.keymap.set("n", "<C-s>", ":lua Ftplugin_Vim.format_and_save()<CR>", { noremap = true, silent = true, buffer = 0 })
