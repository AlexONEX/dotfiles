vim.bo.commentstring = "// %s"
vim.bo.expandtab = true
vim.bo.shiftwidth = 4
vim.bo.softtabstop = 4
vim.bo.tabstop = 4
vim.opt_local.formatoptions:remove({ "o", "r" })

local cpp_flags = table.concat({
	"-Wall",
	"-Wextra",
	"-pedantic",
	"-std=c++17",
	"-O2",
	"-Wshadow",
	"-Wformat=2",
	"-Wfloat-equal",
	"-Wconversion",
	"-Wcast-qual",
	"-Wcast-align",
	"-D_GLIBCXX_DEBUG",
	"-D_GLIBCXX_DEBUG_PEDANTIC",
	"-D_FORTIFY_SOURCE=2",
	"-fsanitize=address",
	"-fsanitize=undefined",
	"-fno-sanitize-recover",
	"-fstack-protector",
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

local function get_cpp_compiler()
	if utils.executable("clang++") then
		return "clang++"
	elseif utils.executable("g++") then
		return "g++"
	else
		return nil
	end
end

function M.compile_run_cpp()
	local compiler = get_cpp_compiler()
	if not compiler then
		vim.notify("No C++ compiler found on the system!", vim.log.levels.ERROR)
		return
	end

	local src_path = vim.fn.expand("%:p:~")
	local src_noext = vim.fn.expand("%:p:~:r")

	create_term_buf("h", 20)
	local cmd = string.format("term %s %s %s -o %s && %s", compiler, cpp_flags, src_path, src_noext, src_noext)
	vim.cmd(cmd)
	vim.cmd("startinsert")
end

function M.compile_only_cpp()
	local compiler = get_cpp_compiler()
	if not compiler then
		vim.notify("No C++ compiler found!", vim.log.levels.ERROR)
		return
	end

	local src_path = vim.fn.expand("%:p:~")
	local src_noext = vim.fn.expand("%:p:~:r")

	create_term_buf("h", 15)
	local cmd = string.format("term %s %s %s -o %s", compiler, cpp_flags, src_path, src_noext)
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

function M.format_cpp()
	if utils.executable("clang-format") then
		vim.cmd("silent !clang-format -i %")
		vim.cmd("edit")
		vim.notify("Formatted with clang-format", vim.log.levels.INFO)
	else
		vim.notify("clang-format not found", vim.log.levels.WARN)
	end
end

function M.debug_cpp()
	local exe_path = vim.fn.expand("%:p:~:r")
	if vim.fn.filereadable(exe_path) == 0 then
		vim.notify("Executable not found. Compile first!", vim.log.levels.WARN)
		return
	end

	if utils.executable("gdb") then
		create_term_buf("h", 20)
		local cmd = string.format("term gdb %s", exe_path)
		vim.cmd(cmd)
		vim.cmd("startinsert")
	else
		vim.notify("gdb not found", vim.log.levels.WARN)
	end
end

_G.Ftplugin_Cpp = M

local opts = { buffer = true, silent = true }

vim.keymap.set("n", "<F9>", function()
	Ftplugin_Cpp.compile_run_cpp()
end, opts)

vim.keymap.set("n", "<F11>", function()
	Ftplugin_Cpp.compile_run_cpp()
end, opts)

vim.keymap.set("n", "<F5>", function()
	Ftplugin_Cpp.compile_only_cpp()
end, { buffer = true, desc = "Compile C++" })

vim.keymap.set("n", "<F6>", function()
	Ftplugin_Cpp.run_executable()
end, { buffer = true, desc = "Run executable" })

vim.keymap.set("n", "<space>f", function()
	Ftplugin_Cpp.format_cpp()
end, { buffer = true, desc = "Format with clang-format" })

vim.keymap.set("n", "<F7>", function()
	Ftplugin_Cpp.debug_cpp()
end, { buffer = true, desc = "Debug with GDB" })
