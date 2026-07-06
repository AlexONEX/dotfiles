-- Copy relative file path (relative to project root) to clipboard
vim.api.nvim_create_user_command("CopyPath", function()
  local full_path = vim.fn.glob("%:p")
  local project_root = vim.fs.root(0, { ".git", "pyproject.toml" })
  if project_root == nil then
    vim.print("can not find project root")
    return
  end
  vim.fn.setreg("+", vim.fn.substitute(full_path, project_root, "<project-root>", "g"))
  vim.print("Filepath copied to clipboard!")
end, { desc = "Copy relative file path to clipboard" })

-- JSON format part of or the whole file
vim.api.nvim_create_user_command("JSONFormat", function(context)
  local range = context["range"]
  local line1 = context["line1"]
  local line2 = context["line2"]

  if range == 0 then
    -- the command is invoked without range, then we assume whole buffer
    local cmd_str = string.format("%s,%s!python -m json.tool", line1, line2)
    vim.fn.execute(cmd_str)
  elseif range == 2 then
    -- the command is invoked with some range
    local cmd_str = string.format("%s,%s!python -m json.tool", line1, line2)
    vim.fn.execute(cmd_str)
  else
    local msg = string.format("unsupported range: %s", range)
    vim.api.nvim_echo({ { msg } }, true, { err = true })
  end
end, {
  desc = "Format JSON string",
  range = "%",
})
