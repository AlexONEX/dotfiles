vim.bo.commentstring = "// %s"
vim.opt_local.formatoptions:remove({ "o", "r" })

local cpp_flags =
	"-Wall -Wextra -pedantic -std=c++17 -O2 -Wshadow -Wformat=2 -Wfloat-equal -Wconversion -Wcast-qual -Wcast-align -D_GLIBCXX_DEBUG -D_GLIBCXX_DEBUG_PEDANTIC -D_FORTIFY_SOURCE=2 -fsanitize=address -fsanitize=undefined -fno-sanitize-recover -fstack-protector"

local M = {}

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

function M.compile_run_cpp()
	local src_path = vim.fn.expand("%:p:~")
	local src_noext = vim.fn.expand("%:p:~:r")
	local prog = ""
	if vim.fn.executable("clang++") == 1 then
		prog = "clang++"
	elseif vim.fn.executable("g++") == 1 then
		prog = "g++"
	else
		vim.notify("No C++ compiler found on the system!", vim.log.levels.ERROR)
		return
	end
	create_term_buf("h", 20)
	local cmd = string.format("term %s %s %s -o %s && %s", prog, cpp_flags, src_path, src_noext, src_noext)
	vim.cmd(cmd)
	vim.cmd("startinsert")
end

_G.Ftplugin_Cpp = M

vim.keymap.set("n", "<F9>", ":lua Ftplugin_Cpp.compile_run_cpp()<CR>", { noremap = true, silent = true, buffer = 0 })
vim.keymap.set("n", "<F11>", ":lua Ftplugin_Cpp.compile_run_cpp()<CR>", { noremap = true, silent = true, buffer = 0 })
