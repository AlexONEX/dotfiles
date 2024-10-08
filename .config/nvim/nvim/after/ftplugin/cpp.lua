vim.bo.commentstring = "// %s"
vim.opt_local.formatoptions:remove({ "o", "r" })

local M = {}

local cpp_flags =
"-Wall -Wextra -pedantic -std=c++11 -O2 -Wshadow -Wformat=2 -Wfloat-equal -Wconversion -Wcast-qual -Wcast-align -D_GLIBCXX_DEBUG -D_GLIBCXX_DEBUG_PEDANTIC -D_FORTIFY_SOURCE=2 -fsanitize=address -fsanitize=undefined -fno-sanitize-recover -fstack-protector"

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
    vim.api.nvim_err_writeln("No C++ compiler found on the system!")
    return
  end
  create_term_buf("h", 20)
  local cmd = string.format("term %s %s %s -o %s && %s", prog, cpp_flags, src_path, src_noext, src_noext)
  vim.cmd(cmd)
  vim.cmd("startinsert")
end

function M.setup()
  vim.api.nvim_buf_set_keymap(0, "n", "<F9>", ":lua CppUtils.compile_run_cpp()<CR>", { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(0, "n", "<F11>", ":lua CppUtils.compile_run_cpp()<CR>", { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(0, "n", "<C-s>", ":lua vim.lsp.buf.format()<CR>", { noremap = true, silent = true })
end

_G.CppUtils = M

return M
