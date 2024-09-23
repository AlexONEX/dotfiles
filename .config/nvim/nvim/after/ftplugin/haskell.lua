vim.bo.commentstring = "-- %s"
vim.opt_local.formatoptions:remove({ "o", "r" })

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

-- Función para compilar y ejecutar Haskell
function compile_run_haskell()
	local src_path = vim.fn.expand("%:p:~")
	local src_noext = vim.fn.expand("%:p:~:r")

	if vim.fn.executable("ghc") == 1 then
		create_term_buf("h", 20)
		local cmd = string.format("term ghc %s %s -o %s && %s", haskell_flags, src_path, src_noext, src_noext)
		vim.cmd(cmd)
	else
		vim.api.nvim_err_writeln("GHC not found on the system!")
		return
	end
	vim.cmd("startinsert")
end

-- Función para crear un buffer de terminal (igual que antes)
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

-- Función para ejecutar Haskell con runhaskell (sin compilación)
function run_haskell()
	local src_path = vim.fn.expand("%:p:~")

	if vim.fn.executable("runhaskell") == 1 then
		create_term_buf("h", 20)
		local cmd = string.format("term runhaskell %s", src_path)
		vim.cmd(cmd)
	else
		vim.api.nvim_err_writeln("runhaskell not found on the system!")
		return
	end
	vim.cmd("startinsert")
end

-- Función para formatear con Ormolu
function format_haskell()
	if vim.fn.executable("ormolu") == 1 then
		vim.cmd("silent %!ormolu")
	else
		vim.api.nvim_err_writeln("Ormolu not found on the system!")
	end
end

-- Función para ejecutar HLint
function run_hlint()
	if vim.fn.executable("hlint") == 1 then
		create_term_buf("h", 20)
		local cmd = string.format("term hlint %s", vim.fn.expand("%:p:~"))
		vim.cmd(cmd)
	else
		vim.api.nvim_err_writeln("HLint not found on the system!")
	end
end

-- Mapeo de teclas
vim.api.nvim_buf_set_keymap(0, "n", "<F9>", ":lua compile_run_haskell()<CR>", { noremap = true, silent = true })
vim.api.nvim_buf_set_keymap(0, "n", "<F10>", ":lua run_haskell()<CR>", { noremap = true, silent = true })
vim.api.nvim_buf_set_keymap(0, "n", "<F11>", ":lua compile_run_haskell()<CR>", { noremap = true, silent = true })
vim.api.nvim_buf_set_keymap(0, "n", "<C-s>", ":lua format_haskell()<CR>", { noremap = true, silent = true })
vim.api.nvim_buf_set_keymap(0, "n", "<leader>hl", ":lua run_hlint()<CR>", { noremap = true, silent = true })

-- Configuración de LSP para Haskell
local lspconfig = require("lspconfig")
lspconfig.hls.setup({})

-- Configuración de null-ls para Ormolu y HLint
local null_ls = require("null-ls")
null_ls.setup({
	sources = {
		null_ls.builtins.formatting.ormolu,
		null_ls.builtins.diagnostics.hlint,
	},
})
