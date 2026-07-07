vim.bo.commentstring = "--\\ %s"
vim.opt_local.formatoptions:remove { "o", "r" }

local M = {}
local utils = require("utils")

function M.format_and_save()
  if utils.executable("sqlfluff") then
    vim.cmd("silent !sqlfluff fix --force %")
    vim.cmd("edit")
    vim.cmd("write")
    vim.notify("Formatted with sqlfluff", vim.log.levels.INFO)
  else
    vim.notify("sqlfluff not found. Install with: pip install sqlfluff", vim.log.levels.WARN)
  end
end

_G.M = M

local opts = { buffer = true, silent = true }
vim.keymap.set("n", "<C-s>", function()
  M.format_and_save()
end, opts)
