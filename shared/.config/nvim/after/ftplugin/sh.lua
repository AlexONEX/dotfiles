vim.bo.expandtab = true
vim.bo.shiftwidth = 2
vim.bo.softtabstop = 2
vim.bo.tabstop = 2
vim.opt_local.formatoptions:remove { "o", "r" }
vim.opt.isfname:remove("=")

local M = {}

function M.run_bash()
  if vim.fn.executable("bash") > 0 then
    vim.cmd("!bash %")
  else
    vim.notify("Bash not found", vim.log.levels.ERROR)
  end
end

local opts = { buffer = true, silent = true }
vim.keymap.set("n", "<F9>", function()
  M.run_bash()
end, opts)

return M
