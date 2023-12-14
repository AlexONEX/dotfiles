local M = {}

-- Formatter for C/C++ files
function M.format_with_clang_format()
  local file = vim.api.nvim_buf_get_name(0)
  vim.cmd(string.format("silent !clang-format -i %s > /dev/null 2>&1", file))
  vim.cmd("silent edit!")
end

-- Formatter for Python files
function M.format_with_ruff()
  local file = vim.api.nvim_buf_get_name(0)
  vim.cmd(string.format("silent !ruff %s", file))
end

--
function M.format_with_prettier()
  local file = vim.api.nvim_buf_get_name(0)
  vim.cmd(string.format("silent !prettier --write %s", file))
end

-- Formatter for Lua files
function M.format_with_stylua()
  local file = vim.api.nvim_buf_get_name(0)
  vim.cmd(string.format("silent !stylua %s", file))
end

-- Formatter for Go files
function M.format_with_gofmt()
  local file = vim.api.nvim_buf_get_name(0)
  vim.cmd(string.format("silent !gofmt -w %s", file))
end

-- Formatter for Rust files
function M.format_with_rustfmt()
  local file = vim.api.nvim_buf_get_name(0)
  vim.cmd(string.format("silent !rustfmt %s", file))
end

-- Formatter for JavaScript and TypeScript files using ESLint
function M.format_with_eslint()
  local file = vim.api.nvim_buf_get_name(0)
  vim.cmd(string.format("silent !eslint --fix %s", file))
end

-- Formatter for docker
function M.format_with_dockfmt()
  local file = vim.api.nvim_buf_get_name(0)
  vim.cmd(string.format("silent !dockfmt fmt %s", file))
  vim.cmd("edit!") -- This reloads the buffer after formatting
end

function M.format_with_latexindent()
  local file = vim.api.nvim_buf_get_name(0)
  vim.cmd(string.format("silent !latexindent -w %s", file))
  vim.cmd("edit!") -- This reloads the buffer after formatting
end

return M
