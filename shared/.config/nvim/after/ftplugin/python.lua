vim.opt_local.wrap = false
vim.opt_local.sidescroll = 5
vim.opt_local.sidescrolloff = 2
vim.opt_local.colorcolumn = "100"
vim.bo.expandtab = true
vim.bo.shiftwidth = 4
vim.bo.softtabstop = 4
vim.bo.tabstop = 4
vim.opt_local.formatoptions:remove { "o", "r" }

local M = {}
local utils = require("utils")
local python_lib = require("python")

vim.api.nvim_create_autocmd("InsertCharPre", {
  pattern = { "*.py" },
  group = vim.api.nvim_create_augroup("py-fstring", { clear = true }),
  callback = function(params)
    if vim.v.char ~= "{" then
      return
    end
    local node = vim.treesitter.get_node {}
    if not node then
      return
    end
    if node:type() ~= "string" then
      node = node:parent()
    end
    if not node or node:type() ~= "string" then
      return
    end
    local row, col = vim.treesitter.get_node_range(node)
    local first_char = vim.api.nvim_buf_get_text(params.buf, row, col, row, col + 1, {})[1]
    if first_char == "f" or first_char == "r" then
      return
    end
    vim.api.nvim_input("<Esc>m'" .. row + 1 .. "gg" .. col + 1 .. "|if<esc>`'la")
  end,
})

function M.run_python()
  local python_info = python_lib.get_python_info()
  vim.cmd("AsyncRun " .. python_info.exe .. ' -u "%"')
end

function M.lint_python()
  if utils.executable("ruff") then
    vim.cmd("!ruff check %")
  else
    vim.notify("Ruff not found", vim.log.levels.WARN)
  end
end

_G.M = M

local opts = { buffer = true, silent = true }
vim.keymap.set("n", "<F9>", function()
  M.run_python()
end, opts)
vim.keymap.set("n", "<space>l", function()
  M.lint_python()
end, opts)
