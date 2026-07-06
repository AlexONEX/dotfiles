vim.bo.expandtab = true
vim.bo.shiftwidth = 2
vim.bo.softtabstop = 2
vim.bo.tabstop = 2
vim.opt_local.formatoptions:remove({ "o", "r" })

local M = {}
local utils = require("utils")

function M.format_and_save()
  if utils.executable("prettier") then
    vim.cmd("silent !prettier --write %")
    vim.cmd("edit")
    vim.cmd("write")
    vim.notify("Formatted with prettier", vim.log.levels.INFO)
  else
    vim.lsp.buf.format({ async = false })
    vim.cmd("write")
  end
end

_G.M = M

local opts = { buffer = true, silent = true }
vim.keymap.set("n", "<C-s>", function() M.format_and_save() end, opts)
vim.keymap.set("n", "<space>f", function() M.format_and_save() end, opts)
