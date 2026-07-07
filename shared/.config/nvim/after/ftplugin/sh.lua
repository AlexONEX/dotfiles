vim.bo.expandtab = true
vim.bo.shiftwidth = 2
vim.bo.softtabstop = 2
vim.bo.tabstop = 2
vim.opt_local.formatoptions:remove { "o", "r" }
vim.opt.isfname:remove("=")

local M = {}
local utils = require("utils")

function M.run_bash()
  if utils.executable("bash") then
    vim.cmd("!bash %")
  else
    vim.notify("Bash not found", vim.log.levels.ERROR)
  end
end

_G.M = M

local opts = { buffer = true, silent = true }
vim.keymap.set("n", "<F9>", function()
  M.run_bash()
end, opts)
