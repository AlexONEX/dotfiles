-- Custom text objects (migrated from autoload/text_obj.vim)

local M = {}

--- Select URL under cursor (operator-pending & visual mode text object).
function M.url()
  local url_pattern
  -- Try to use vim-highlighturl pattern if available
  if vim.g.loaded_highlighturl then
    -- vim-highlighturl provides highlighturl#default_pattern()
    url_pattern = vim.fn["highlighturl#default_pattern"]()
  else
    url_pattern = vim.fn.expand("<cfile>")
    if #url_pattern <= 10 then
      return
    end
  end

  local line_text = vim.fn.getline(".")
  local url_infos = {}

  local idx = 1
  while true do
    local s, e = line_text:find(url_pattern, idx)
    if not s then
      break
    end
    table.insert(url_infos, { s, e })
    idx = e + 1
  end

  if #url_infos == 0 then
    return
  end

  local cur_col = vim.fn.getcurpos()[3]
  local start_col, end_col = -1, -1
  for _, info in ipairs(url_infos) do
    local s, e = info[1], info[2]
    if cur_col >= s and cur_col <= e then
      start_col = s
      end_col = e
      break
    end
  end

  if start_col == -1 then
    return
  end

  local buf_num = vim.fn.bufnr()
  local cur_row = vim.fn.line(".")
  vim.fn.setpos("'<", { buf_num, cur_row, start_col, 0 })
  vim.fn.setpos("'>", { buf_num, cur_row, end_col, 0 })
  vim.cmd("normal! gv")
end

--- Select a markdown code block (inner or around).
function M.md_code_block(type)
  vim.cmd("normal! $")
  local start_row = vim.fn.searchpos("\\s*```", "bnW")[1]
  local end_row = vim.fn.searchpos("\\s*```", "nW")[1]

  local buf_num = vim.fn.bufnr()
  if type == "i" then
    start_row = start_row + 1
    end_row = end_row - 1
  end

  vim.fn.setpos("'<", { buf_num, start_row, 1, 0 })
  vim.fn.setpos("'>", { buf_num, end_row, 1, 0 })
  vim.cmd("normal! `<V`>")
end

--- Select the entire buffer.
function M.buffer()
  local buf_num = vim.fn.bufnr()
  vim.fn.setpos("'<", { buf_num, 1, 1, 0 })
  vim.fn.setpos("'>", { buf_num, vim.fn.line("$"), 1, 0 })
  vim.cmd("normal! `<V`>")
end

return M
