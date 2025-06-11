vim.bo.commentstring = "-- %s"
vim.bo.expandtab = true
vim.bo.shiftwidth = 2
vim.bo.softtabstop = 2
vim.bo.tabstop = 2
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

local M = {}
local utils = require("utils")

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
	if not utils.executable("ghc") then
		vim.notify("GHC not found on the system!", vim.log.levels.ERROR)
		return
	end

	local src_path = vim.fn.expand("%:p:~")
	local src_noext = vim.fn.expand("%:p:~:r")

	create_term_buf("h", 20)
	local cmd = string.format("term ghc %s %s -o %s && %s", haskell_flags, src_path, src_noext, src_noext)
	vim.cmd(cmd)
	vim.cmd("startinsert")
end

function M.run_haskell()
	if not utils.executable("runhaskell") then
		vim.notify("runhaskell not found on the system!", vim.log.levels.ERROR)
		return
	end

	local src_path = vim.fn.expand("%:p:~")
	create_term_buf("h", 20)
	local cmd = string.format("term runhaskell %s", src_path)
	vim.cmd(cmd)
	vim.cmd("startinsert")
end

function M.format_haskell()
	if not utils.executable("ormolu") then
		vim.notify("ormolu not found on the system!", vim.log.levels.ERROR)
		return
	end

	local src_path = vim.fn.expand("%:p")
	vim.cmd("write")
	local result = vim.fn.system(string.format("ormolu --mode inplace %s", vim.fn.shellescape(src_path)))
	if vim.v.shell_error == 0 then
		vim.cmd("edit!")
		vim.notify("Formatted with ormolu", vim.log.levels.INFO)
	else
		vim.notify("Error formatting file: " .. result, vim.log.levels.ERROR)
	end
end

function M.run_hlint()
	vim.lsp.buf.code_action()
end

function M.compile_only_haskell()
	if not utils.executable("ghc") then
		vim.notify("GHC not found!", vim.log.levels.ERROR)
		return
	end

	local src_path = vim.fn.expand("%:p:~")
	local src_noext = vim.fn.expand("%:p:~:r")

	create_term_buf("h", 15)
	local cmd = string.format("term ghc %s %s -o %s", haskell_flags, src_path, src_noext)
	vim.cmd(cmd)
	vim.cmd("startinsert")
end

function M.run_executable()
	local exe_path = vim.fn.expand("%:p:~:r")
	if vim.fn.filereadable(exe_path) == 0 then
		vim.notify("Executable not found. Compile first!", vim.log.levels.WARN)
		return
	end

	create_term_buf("h", 15)
	local cmd = string.format("term %s", exe_path)
	vim.cmd(cmd)
	vim.cmd("startinsert")
end

_G.Ftplugin_Haskell = M

local opts = { buffer = true, silent = true }
vim.keymap.set("n", "<F9>", function()
	Ftplugin_Haskell.compile_run_haskell()
end, opts)
vim.keymap.set("n", "<F10>", function()
	Ftplugin_Haskell.run_haskell()
end, opts)
vim.keymap.set("n", "<F11>", function()
	Ftplugin_Haskell.compile_run_haskell()
end, opts)
vim.keymap.set("n", "<F5>", function()
	Ftplugin_Haskell.compile_only_haskell()
end, opts)
vim.keymap.set("n", "<F6>", function()
	Ftplugin_Haskell.run_executable()
end, opts)
vim.keymap.set("n", "<C-s>", function()
	Ftplugin_Haskell.format_haskell()
end, opts)
vim.keymap.set("n", "<space>f", function()
	Ftplugin_Haskell.format_haskell()
end, opts)
vim.keymap.set("n", "<leader>hl", function()
	Ftplugin_Haskell.run_hlint()
end, opts)
