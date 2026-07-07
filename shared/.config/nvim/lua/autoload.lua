-- Replacement for the used functions in autoload/utils.vim
-- Dead functions from the original (VimFolds, MyFoldText, Inside_git_repo, GetGitBranch) not ported.

local M = {}

--- Create a command-mode abbreviation safely.
function M.cabbrev(key, value)
  local escaped = value:gsub("'", "''")
  local cmd = string.format(
    [[cabbrev <expr> %s (getcmdtype() == ":" && getcmdpos() <= %d) ? '%s' : '%s']],
    key,
    1 + #key,
    escaped,
    key
  )
  vim.cmd(cmd)
end

--- Get a title string for the window title (hostname + path + last-modified).
function M.get_titlestr()
  local title = ""
  if vim.g.is_linux then
    title = vim.fn.hostname() .. "  "
  end
  local buf_path = vim.fn.expand("%:p:~")
  title = title .. buf_path .. "  "
  if vim.bo.buflisted and buf_path ~= "" then
    title = title .. os.date("%Y-%m-%d %H:%M:%S%z", vim.fn.getftime(vim.fn.expand("%")))
  end
  return title
end

--- Toggle cursor column.
function M.toggle_cursor_col()
  if vim.wo.cursorcolumn then
    vim.wo.cursorcolumn = false
    vim.print("cursorcolumn: OFF")
  else
    vim.wo.cursorcolumn = true
    vim.print("cursorcolumn: ON")
  end
end

--- Switch a line up or down.
function M.switch_line(src_line_idx, direction)
  if direction == "up" then
    if src_line_idx == 1 then
      return
    end
    vim.cmd("move-2")
  elseif direction == "down" then
    if src_line_idx == vim.fn.line("$") then
      return
    end
    vim.cmd("move+1")
  end
end

--- Move visual selection up or down.
function M.move_selection(direction)
  if vim.fn.visualmode() ~= "V" then
    return
  end
  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")
  local num_line = end_line - start_line + 1

  if direction == "up" then
    if start_line == 1 then
      vim.cmd("normal! gv")
      return
    end
    vim.cmd(string.format("%s,%smove-2", start_line, end_line))
    vim.cmd("normal! gv")
  elseif direction == "down" then
    if end_line == vim.fn.line("$") then
      vim.cmd("normal! gv")
      return
    end
    vim.cmd(string.format("%s,%smove+%s", start_line, end_line, num_line))
    vim.cmd("normal! gv")
  end
end

--- Capture command output to a scratch buffer.
function M.capture_command_output(command)
  local output = vim.fn.execute(command)
  vim.cmd("tabnew | setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile")
  local lines = vim.split(output, "\n")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
end

--- Convert a timestamp (ms/us/s) to ISO time string, or return current time if nil.
function M.iso_time(timestamp)
  if not timestamp or timestamp == "" then
    return os.date("%Y-%m-%d %H:%M:%S%z")
  end
  local ts = tonumber(timestamp)
  if not ts then
    return os.date("%Y-%m-%d %H:%M:%S%z")
  end
  if ts >= 1e13 then
    ts = ts / 1000
  elseif ts >= 1e16 then
    ts = ts / 1000000
  end
  return os.date("%Y-%m-%d %H:%M:%S%z", ts)
end

--- Edit files matching patterns.
function M.multi_edit(patterns)
  for _, p in ipairs(vim.split(patterns, "%s+")) do
    local files = vim.fn.glob(p, false, true)
    for _, f in ipairs(files) do
      vim.cmd("edit " .. f)
    end
  end
end

return M
