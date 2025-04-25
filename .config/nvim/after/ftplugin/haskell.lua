local M = {}

vim.bo.commentstring = "-- %s"
vim.opt_local.formatoptions:remove({ "o", "r" })
vim.b.matchup_enabled = 0

local haskell_flags = table.concat({
	"-Wall",
	"-Wcompat",
	"-Wincomplete-record-updates",
	"-Wincomplete-uni-patterns",
	"-Wredundant-constraints",
	"-Wmissing-export-lists",
	"-Wpartial-fields",
	"-Wmissing-deriving-strategies",
	"-Wunused-packages",
	"-Widentities",
	"-fhide-source-paths",
	"-freverse-errors",
	"-fdefer-typed-holes",
	"-fdefer-type-errors",
	"-O2",
	"-dynamic",
	"-threaded",
	"-eventlog",
	"-debug",
}, " ")

local function create_term_buf(type, size)
	vim.opt.splitbelow = true
	vim.opt.splitright = true
	if type == "v" then
		vim.cmd("vnew")
	else
		vim.cmd("new")
	end
	vim.cmd("resize " .. size)
end

function M.compile_run_haskell()
	local src_path = vim.fn.expand("%:p:~")
	local src_noext = vim.fn.expand("%:p:~:r")
	if vim.fn.executable("ghc") == 1 then
		create_term_buf("h", 20)
		local cmd = string.format("term ghc %s %s -o %s && %s", haskell_flags, src_path, src_noext, src_noext)
		vim.cmd(cmd)
	else
		vim.notify("GHC not found on the system!", vim.log.levels.ERROR)
		return
	end
	vim.cmd("startinsert")
end

function M.run_haskell()
	local src_path = vim.fn.expand("%:p:~")
	if vim.fn.executable("runhaskell") == 1 then
		create_term_buf("h", 20)
		local cmd = string.format("term runhaskell %s", src_path)
		vim.cmd(cmd)
	else
		vim.notify("runhaskell not found on the system!", vim.log.levels.ERROR)
		return
	end
	vim.cmd("startinsert")
end

function M.format_haskell()
	vim.cmd("Neoformat ormolu")
end

function M.run_hlint()
	vim.lsp.buf.code_action()
end

function M.setup()
	-- Use vim.keymap.set instead of vim.api.nvim_buf_set_keymap
	vim.keymap.set(
		"n",
		"<F9>",
		":lua HaskellUtils.compile_run_haskell()<CR>",
		{ noremap = true, silent = true, buffer = 0 }
	)
	vim.keymap.set("n", "<F10>", ":lua HaskellUtils.run_haskell()<CR>", { noremap = true, silent = true, buffer = 0 })
	vim.keymap.set(
		"n",
		"<F11>",
		":lua HaskellUtils.compile_run_haskell()<CR>",
		{ noremap = true, silent = true, buffer = 0 }
	)
	vim.keymap.set(
		"n",
		"<C-s>",
		":lua HaskellUtils.format_haskell()<CR>",
		{ noremap = true, silent = true, buffer = 0 }
	)
	vim.keymap.set(
		"n",
		"<leader>hl",
		":lua HaskellUtils.run_hlint()<CR>",
		{ noremap = true, silent = true, buffer = 0 }
	)

	local lspconfig = require("lspconfig")
	lspconfig.hls.setup({
		settings = {
			haskell = {
				formattingProvider = "ormolu",
				checkProject = true,
			},
		},
	})

	vim.g.neoformat_enabled_haskell = { "ormolu" }
	vim.g.neoformat_try_formatprg = 1
end

_G.HaskellUtils = M

-- Call setup immediately, no need to call it from other places
M.setup()

return M
