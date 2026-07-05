vim.bo.expandtab = true
vim.bo.shiftwidth = 2
vim.bo.softtabstop = 2
vim.bo.tabstop = 2
vim.opt_local.formatoptions:remove({ "o", "r" })

local M = {}
local utils = require("utils")

function M.format_and_save()
  if utils.executable("terraform") then
    vim.cmd("silent !terraform fmt %")
    vim.cmd("edit")
    vim.cmd("write")
    vim.notify("Formatted with terraform fmt", vim.log.levels.INFO)
  else
    vim.notify("terraform not found in PATH", vim.log.levels.WARN)
  end
end

_G.Ftplugin_Terraform = M

local opts = { buffer = true, silent = true }
vim.keymap.set("n", "<C-s>", function() Ftplugin_Terraform.format_and_save() end, opts)
vim.keymap.set("n", "<space>f", function() Ftplugin_Terraform.format_and_save() end, opts)
