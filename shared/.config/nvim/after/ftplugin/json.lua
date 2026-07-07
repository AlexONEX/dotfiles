vim.bo.expandtab = true
vim.bo.shiftwidth = 2
vim.bo.softtabstop = 2
vim.bo.tabstop = 2
vim.opt_local.formatoptions:remove { "o", "r" }

vim.keymap.set("n", "o", function()
  local line = vim.api.nvim_get_current_line()
  if line:match("[^,{[]\\s*$") then
    return "A,<cr>"
  else
    return "o"
  end
end, { buffer = true, expr = true, desc = "Smart 'o' for commas" })
