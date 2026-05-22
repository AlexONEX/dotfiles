local utils = require("utils")

vim.bo.expandtab = true
vim.bo.shiftwidth = 2
vim.bo.softtabstop = 2
vim.bo.tabstop = 2
vim.opt_local.formatoptions:remove { "o", "r" }

local M = {}

function M.format_json()
  if not utils.executable("jq") then
    vim.notify("jq not found in system", vim.log.levels.WARN, { title = "JSON Format" })
    return
  end

  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  vim.cmd([[ silent %!jq . ]])
  vim.api.nvim_win_set_cursor(0, cursor_pos)
  vim.notify("JSON formateado con jq.", vim.log.levels.INFO, { title = "JSON Format" })
end

vim.keymap.set("n", "<leader>f", M.format_json, {
  buffer = true,
  desc = "Format JSON with jq",
})

vim.keymap.set("n", "o", function()
  local line = vim.api.nvim_get_current_line()
  if line:match("[^,{[]\\s*$") then
    return "A,<cr>"
  else
    return "o"
  end
end, { buffer = true, expr = true, desc = "Smart 'o' for commas" })

return M
