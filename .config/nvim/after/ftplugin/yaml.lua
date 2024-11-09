local M = {}

vim.opt_local.formatoptions:remove { "o", "r" }
vim.opt_local.expandtab = true
vim.opt_local.shiftwidth = 2
vim.opt_local.softtabstop = 2

-- Disable syntax for large YAML files
if vim.fn.line("$") > 500 then
  vim.opt_local.syntax = "OFF"
end

function M.format_and_save_yaml()
  -- Check if yaml formatter is available (e.g., yamlfmt or prettier)
  local formatters = { "yamlfmt", "prettier --parser yaml" }
  local formatter = ""

  for _, fmt in ipairs(formatters) do
    if vim.fn.executable(vim.split(fmt, " ")[1]) == 1 then
      formatter = fmt
      break
    end
  end

  if formatter ~= "" then
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local content = table.concat(lines, "\n")
    local formatted = vim.fn.system(formatter, content)

    if vim.v.shell_error == 0 then
      vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(formatted, "\n"))
      print("YAML formatted successfully.")
    else
      print("Error formatting YAML: " .. formatted)
    end
  else
    print("No YAML formatter found. Install yamlfmt or prettier for formatting.")
  end
  vim.cmd("write")
end

function M.setup()
  vim.api.nvim_buf_set_keymap(
    0,
    "n",
    "<C-s>",
    ":lua YamlUtils.format_and_save_yaml()<CR>",
    { noremap = true, silent = true }
  )
end

_G.YamlUtils = M
return M
