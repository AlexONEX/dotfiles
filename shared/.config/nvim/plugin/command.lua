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

local autoload = require("autoload")

-- Capture command output to a register
vim.api.nvim_create_user_command("Redir", function(context)
  autoload.capture_command_output(context.args)
end, { nargs = 1, complete = "command", desc = "capture command output to scratch buffer" })

-- Open multiple files matching patterns
vim.api.nvim_create_user_command("Edit", function(context)
  autoload.multi_edit(context.args)
end, { nargs = "+", complete = "file", bar = true, desc = "open files matching patterns" })
vim.cmd("cabbrev edit Edit")

vim.cmd("cabbrev man Man")

-- Show current date and time
vim.api.nvim_create_user_command("Datetime", function(context)
  vim.print(autoload.iso_time(context.args))
end, { nargs = "?", desc = "show current date/time" })

-- Convert Markdown to PDF via pandoc
vim.api.nvim_create_user_command("ToPDF", function()
  if vim.fn.executable("pandoc") ~= 1 then
    vim.notify("pandoc not found", vim.log.levels.ERROR)
    return
  end
  local md_path = vim.fn.expand("%:p")
  local pdf_path = vim.fn.fnamemodify(md_path, ":r") .. ".pdf"
  local header_path = vim.fn.stdpath("config") .. "/resources/head.tex"
  local cmd = table.concat({
    "pandoc",
    "--pdf-engine=xelatex",
    "--highlight-style=zenburn",
    "--table-of-content",
    "--include-in-header=" .. header_path,
    "-V fontsize=10pt",
    "-V colorlinks",
    "-V toccolor=NavyBlue",
    "-V linkcolor=red",
    "-V urlcolor=teal",
    "-V filecolor=magenta",
    "-s",
    md_path,
    "-o",
    pdf_path,
  }, " ")
  if vim.g.is_mac then
    cmd = cmd .. " && open " .. pdf_path
  elseif vim.g.is_win then
    cmd = cmd .. " && start " .. pdf_path
  end
  local id = vim.fn.jobstart(cmd, vim.env.SHELL)
  if id == 0 or id == -1 then
    vim.notify("error running pandoc", vim.log.levels.ERROR)
  end
end, { desc = "convert markdown to PDF" })
