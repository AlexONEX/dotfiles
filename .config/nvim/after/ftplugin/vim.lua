-- Early ret
local b = vim.b
if b.did_vim_ftplugin then
	return
end
b.did_vim_ftplugin = true

-- Local buffer options
local opt = vim.opt_local
opt.expandtab = true
opt.shiftwidth = 2
opt.softtabstop = 2
opt.tabstop = 2
opt.foldmethod = "marker"
opt.foldmarker = "{{{,}}}"

-- Format and save function with LSP support
local function format_and_save()
	local clients = vim.lsp.get_clients()
	local has_lsp = false

	for _, client in ipairs(clients) do
		if client.name == "lua_ls" and client.server_capabilities.documentFormattingProvider then
			has_lsp = true
			break
		end
	end

	-- Save cursor position
	local save_cursor = vim.fn.getpos(".")

	if has_lsp then
		-- Use LSP formatting
		vim.lsp.buf.format({
			timeout_ms = 2000,
			filter = function(client)
				return client.name == "lua_ls"
			end,
			async = false,
		})
	else
		-- Fallback to Vim's native formatting
		vim.cmd([[silent! normal! gg=G]])
	end

	-- Restore cursor position and save
	vim.fn.setpos(".", save_cursor)
	vim.cmd("write")
end

-- Function to run Vim script
local function run_vim_script()
	vim.cmd("source %")
end

-- Key mappings
local opts = { noremap = true, silent = true, buffer = 0 }
vim.keymap.set("n", "<F9>", run_vim_script, opts)
vim.keymap.set("n", "<C-s>", format_and_save, opts)

-- Set up undo_ftplugin
b.undo_ftplugin = (b.undo_ftplugin or "")
	.. "|setlocal expandtab< shiftwidth< softtabstop< tabstop< foldmethod< foldmarker<"
