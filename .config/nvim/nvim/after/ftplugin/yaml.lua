-- YAML-specific settings for Neovim
vim.opt_local.formatoptions:remove { "o", "r" }

-- Disable syntax for large YAML files
if vim.fn.line("$") > 500 then
  vim.opt_local.syntax = "OFF"
end

-- Function to format YAML using external formatter (if available) and save
function FormatAndSaveYml()
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
    -- Get the current buffer contents
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local content = table.concat(lines, "\n")

    -- Format the content using the found formatter
    local formatted = vim.fn.system(formatter, content)

    -- Check if formatting was successful
    if vim.v.shell_error == 0 then
      -- Replace buffer contents with formatted content
      vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(formatted, "\n"))
      print("YAML formatted successfully.")
    else
      print("Error formatting YAML: " .. formatted)
    end
  else
    print("No YAML formatter found. Install yamlfmt or prettier for formatting.")
  end

  -- Save the file
  vim.cmd("write")
end

-- Key mapping
vim.api.nvim_buf_set_keymap(0, "n", "<C-s>", ":lua FormatAndSaveYml()<CR>", { noremap = true, silent = true })

-- Set indentation for YAML files
vim.opt_local.expandtab = true
vim.opt_local.shiftwidth = 2
vim.opt_local.softtabstop = 2

-- You can add more YAML-specific settings here
