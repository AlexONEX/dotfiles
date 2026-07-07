local diagnostic = vim.diagnostic
local api = vim.api

-- global config for diagnostic
diagnostic.config {
  underline = false,
  virtual_text = false,
  virtual_lines = false,
  signs = {
    text = {
      [diagnostic.severity.ERROR] = "🆇",
      [diagnostic.severity.WARN] = "⚠️",
      [diagnostic.severity.INFO] = "ℹ️",
      [diagnostic.severity.HINT] = "",
    },
  },
  severity_sort = true,
  float = {
    source = true,
    header = "Diagnostics:",
    prefix = " ",
    border = "single",
  },
}

-- set quickfix list from diagnostics in a certain buffer, not the whole workspace
local set_qflist = function(buf_num, severity)
  local diagnostics = nil
  diagnostics = diagnostic.get(buf_num, { severity = severity })

  local qf_items = diagnostic.toqflist(diagnostics)
  vim.fn.setqflist({}, " ", { title = "Diagnostics", items = qf_items })

  -- open quickfix by default
  vim.cmd([[copen]])
end

-- this puts diagnostics from opened files to quickfix
vim.keymap.set("n", "<space>qw", diagnostic.setqflist, { desc = "put window diagnostics to qf" })

-- this puts diagnostics from current buffer to quickfix
vim.keymap.set("n", "<space>qb", function()
  set_qflist(0)
end, { desc = "put buffer diagnostics to qf" })

-- export current quickfix list to a file
vim.keymap.set("n", "<space>qe", function()
  local items = vim.fn.getqflist()
  if #items == 0 then
    vim.notify("Quickfix list is empty", vim.log.levels.WARN)
    return
  end
  local lines = vim.tbl_map(function(e)
    return vim.fn.bufname(e.bufnr) .. ":" .. e.lnum .. ":" .. e.col .. ": " .. e.text
  end, items)
  local path = vim.fn.expand("~/quickfix-export.txt")
  vim.fn.writefile(lines, path)
  vim.notify("Exported " .. #lines .. " items to " .. path, vim.log.levels.INFO)
end, { desc = "export quickfix to ~/quickfix-export.txt" })

-- automatically show diagnostic in float win for current line
api.nvim_create_autocmd("CursorHold", {
  pattern = "*",
  callback = function()
    local cursor_pos = api.nvim_win_get_cursor(0)
    if vim.deep_equal(cursor_pos, vim.b.diagnostics_pos) then
      return
    end
    vim.b.diagnostics_pos = cursor_pos

    -- only open float if there's actually a diagnostic on this line
    local line = cursor_pos[1] - 1
    for _, d in ipairs(vim.diagnostic.get(0)) do
      if d.lnum == line then
        diagnostic.open_float { width = 100 }
        return
      end
    end
  end,
})
