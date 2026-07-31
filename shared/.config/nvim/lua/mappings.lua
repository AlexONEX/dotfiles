local keymap = vim.keymap
local uv = vim.uv

-- ─── Command shortcut ───────────────────────────────────────────────────────
keymap.set({ "n", "x" }, ";", ":")

-- ─── Movement ───────────────────────────────────────────────────────────────
keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true })
keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true })
keymap.set("n", "^", "g^")
keymap.set("n", "0", "g0")
keymap.set("x", "$", "g_")
-- H/L = first non-blank start/end  |  HH/LL = absolute start/end
keymap.set({ "n", "x" }, "H", "^")
keymap.set({ "n", "x" }, "L", "g_")
keymap.set({ "n", "x" }, "HH", "<Home>")
keymap.set({ "n", "x" }, "LL", "<End>")
-- Insert / command-line navigation
keymap.set("i", "<C-A>", "<HOME>")
keymap.set("i", "<C-E>", "<END>")
keymap.set("c", "<C-A>", "<HOME>")
-- Window navigation via arrow keys
keymap.set("n", "<left>", "<c-w>h")
keymap.set("n", "<Right>", "<C-W>l")
keymap.set("n", "<Up>", "<C-W>k")
keymap.set("n", "<Down>", "<C-W>j")

-- ─── Text Editing ───────────────────────────────────────────────────────────
-- Change without contaminating register
keymap.set("n", "c", '"_c')
keymap.set("n", "C", '"_C')
keymap.set("n", "cc", '"_cc')
keymap.set("x", "c", '"_c')
-- Paste from register without contaminating it
keymap.set("x", "p", '"_c<Esc>p')
-- Join lines without moving cursor
keymap.set("n", "J", function()
  vim.cmd([[
      normal! mzJ`z
      delmarks z
    ]])
end, { desc = "join lines without moving cursor" })
keymap.set("n", "gJ", function()
  -- must use `normal!` to avoid recursive mapping
  vim.cmd([[
      normal! mzgJ`z
      delmarks z
    ]])
end, { desc = "join lines without moving cursor" })
-- Move line / selection up and down
local autoload = require("autoload")
keymap.set("n", "<A-k>", function()
  autoload.switch_line(vim.fn.line("."), "up")
end, { desc = "move line up" })
keymap.set("n", "<A-j>", function()
  autoload.switch_line(vim.fn.line("."), "down")
end, { desc = "move line down" })
keymap.set("x", "<A-k>", function()
  autoload.move_selection("up")
end, { desc = "move selection up" })
keymap.set("x", "<A-j>", function()
  autoload.move_selection("down")
end, { desc = "move selection down" })
-- Insert blank line without moving cursor
keymap.set("n", "<space>o", function()
  vim.cmd("normal! m`" .. vim.v.count1 .. "o\027``")
end, { desc = "insert line below" })
keymap.set("n", "<space>O", function()
  vim.cmd("normal! m`" .. vim.v.count1 .. "O\027``")
end, { desc = "insert line above" })
-- Visual indent stays in visual mode
keymap.set("x", "<", "<gv")
keymap.set("x", ">", ">gv")
-- Insert-mode case transforms
keymap.set("i", "<c-u>", "<Esc>viwUea")
keymap.set("i", "<c-t>", "<Esc>b~lea")
-- Insert semicolon at end of line
keymap.set("i", "<A-;>", "<Esc>miA;<Esc>`ii")
-- Paste above / below current line (non-linewise)
keymap.set("n", "<leader>p", "m`o<ESC>p``", { desc = "paste below current line" })
keymap.set("n", "<leader>P", "m`O<ESC>p``", { desc = "paste above current line" })
-- Reselect last pasted area
keymap.set("n", "<leader>v", function()
  local t = vim.fn.getregtype()
  local c = (t and #t > 0) and t:sub(1, 1) or "v"
  return "`[" .. c .. "`]"
end, { expr = true, desc = "reselect last pasted area" })
-- Strip trailing whitespace
keymap.set("n", "<leader><space>", "<cmd>StripTrailingWhitespace<cr>", { desc = "remove trailing space" })
-- Break undo units on punctuation in insert mode
local undo_ch = { ",", ".", "!", "?", ";", ":" }
for _, ch in ipairs(undo_ch) do
  keymap.set("i", ch, ch .. "<c-g>u")
end
-- Todo items
keymap.set("n", "<space>nt", "i- [ ] <Esc>A", { desc = "insert new todo item" })
keymap.set("n", "<space>x", function()
  local line = vim.api.nvim_get_current_line()
  local new_line
  if line:match("- %[ %]") then
    new_line = line:gsub("- %[ %]", "- [x]", 1)
  elseif line:match("- %[x%]") then
    new_line = line:gsub("- %[x%]", "- [ ]", 1)
  else
    return
  end
  vim.api.nvim_set_current_line(new_line)
end, { desc = "toggle todo completion status" })

-- ─── Search ─────────────────────────────────────────────────────────────────
keymap.set("n", "/", [[/\v]])

-- ─── Text Objects ───────────────────────────────────────────────────────────
local text_objs = require("text_objs")
keymap.set({ "x", "o" }, "iu", function()
  text_objs.url()
end, { desc = "URL text object" })
keymap.set({ "x", "o" }, "iB", function()
  text_objs.buffer()
end, { desc = "buffer text object" })

-- ─── Buffers ────────────────────────────────────────────────────────────────
local function save_and_switch(cmd)
  if vim.bo.modifiable and not vim.bo.readonly and vim.bo.modified then
    vim.cmd("write")
  end
  vim.cmd(cmd)
end
keymap.set("n", "<Tab>", function()
  save_and_switch("bnext")
end, { desc = "save and next buffer" })
keymap.set("n", "<S-Tab>", function()
  save_and_switch("bprevious")
end, { desc = "save and previous buffer" })
-- Cycle between windows (e.g. explorer ↔ text buffer)
keymap.set("n", "<C-w>", "<C-w>w", { silent = true, desc = "cycle windows" })
keymap.set("n", [[\D]], function()
  local buf_ids = vim.api.nvim_list_bufs()
  local cur_buf = vim.api.nvim_win_get_buf(0)
  for _, buf_id in pairs(buf_ids) do
    if vim.api.nvim_get_option_value("buflisted", { buf = buf_id }) and buf_id ~= cur_buf then
      vim.api.nvim_buf_delete(buf_id, { force = true })
    end
  end
end, { desc = "delete other buffers" })
local buf_utils = require("buf_utils")
keymap.set("n", "gb", function()
  buf_utils.go_to_buffer(vim.v.count, "forward")
end, { desc = "go to buffer (forward)" })
keymap.set("n", "gB", function()
  buf_utils.go_to_buffer(vim.v.count, "backward")
end, { desc = "go to buffer (backward)" })
keymap.set("n", [[\x]], "<cmd>windo lclose <bar> cclose <cr>", { silent = true, desc = "close qf and location list" })

-- ─── File & Clipboard ───────────────────────────────────────────────────────
keymap.set("n", "<leader>y", "<cmd>%yank<cr>", { desc = "yank entire buffer" })
keymap.set("n", "<space>yp", function()
  vim.fn.setreg("+", vim.fn.expand("%:p"))
  vim.print("Copied path: " .. vim.fn.expand("%:p"))
end, { desc = "copy file path" })
keymap.set("n", "<space>yn", function()
  vim.fn.setreg("+", vim.fn.expand("%:t"))
  vim.print("Copied filename: " .. vim.fn.expand("%:t"))
end, { desc = "copy file name" })
keymap.set("n", "gx", function()
  local url = vim.fn.expand("<cfile>")
  local browser = vim.env.BROWSER
  if browser then
    vim.system({ browser, url }, { text = true }):wait()
    vim.notify("Opening: " .. url, vim.log.levels.INFO)
  else
    require("utils").open_url_under_cursor()
  end
end, { desc = "open URL in browser" })

-- ─── Explorer & Workspace ───────────────────────────────────────────────────
keymap.set("n", "<Space>e", function()
  Snacks.explorer { hidden = true }
end, { desc = "file explorer" })
-- Lazygit (requires lazygit installed)
if vim.fn.executable("lazygit") == 1 then
  keymap.set("n", "<leader>gg", function()
    Snacks.lazygit()
  end, { desc = "lazygit" })
end
keymap.set("n", "<leader>cd", "<cmd>lcd %:p:h<cr><cmd>pwd<cr>", { desc = "change cwd" })
keymap.set("n", "<leader>wo", function()
  local wiki_dir = vim.fn.expand("~/wiki")
  if vim.fn.isdirectory(wiki_dir) == 1 then
    vim.cmd("cd " .. wiki_dir)
    vim.notify("Moved to: " .. wiki_dir, vim.log.levels.INFO)
  else
    vim.notify("~/wiki not found: " .. wiki_dir, vim.log.levels.ERROR)
  end
end, { desc = "go to wiki directory" })

-- ─── Format ──────────────────────────────────────────────────────────────────
keymap.set({ "n", "v" }, "<space>cf", function()
  vim.lsp.buf.format()
end, { desc = "format buffer via LSP" })
keymap.set("n", "<C-s>", function()
  vim.lsp.buf.format()
  vim.cmd("write")
end, { desc = "format buffer and save" })

-- ─── Config ─────────────────────────────────────────────────────────────────
keymap.set("n", "<leader>co", "<cmd>tabnew $MYVIMRC <bar> tcd %:h<cr>", { silent = true, desc = "open init.lua" })
keymap.set("n", "<leader>cr", function()
  vim.cmd([[
      update $MYVIMRC
      source $MYVIMRC
    ]])
  vim.notify("Nvim config successfully reloaded!", vim.log.levels.INFO, { title = "nvim-config" })
end, { silent = true, desc = "reload init.lua" })
keymap.set("n", "<leader>q", function()
  if vim.fn.winnr("$") == 1 then
    vim.cmd("qall")
  else
    vim.cmd("close")
  end
end, { silent = true, desc = "close window or quit" })
keymap.set("n", "<leader>Q", "<cmd>qa!<cr>", { silent = true, desc = "quit nvim" })

-- ─── UI & Misc ──────────────────────────────────────────────────────────────
-- Esc: close float → clear search
keymap.set("n", "<Esc>", function()
  -- close any floating window first
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local ok, config = pcall(vim.api.nvim_win_get_config, win)
    if ok and config and config.relative ~= "" then
      vim.api.nvim_win_close(win, false)
      return
    end
  end
  -- clear search highlight
  pcall(function()
    vim.cmd("nohlsearch")
  end)
  local ns = vim.api.nvim_get_namespaces()["search"]
  if ns then
    pcall(function()
      vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
    end)
  end
end, { desc = "close float → clear search" })
keymap.set("t", "<Esc>", [[<c-\><c-n>]])
keymap.set("n", "<F11>", "<cmd>set spell!<cr>", { desc = "toggle spell" })
keymap.set("i", "<F11>", "<c-o><cmd>set spell!<cr>", { desc = "toggle spell" })
keymap.set("n", "<leader>cl", function()
  require("autoload").toggle_cursor_col()
end, { desc = "toggle cursor column" })
keymap.set("n", "<space>cL", function()
  local log = vim.lsp.log.get_filename()
  -- find existing buffer with the log
  for _, b in ipairs(vim.fn.getbufinfo { buflisted = 1 }) do
    if b.name == log then
      vim.api.nvim_buf_delete(b.bufnr, { force = true })
      return
    end
  end
  vim.cmd("tabnew " .. log)
end, { desc = "toggle LSP log" })
keymap.set("n", "<leader>cb", function()
  local cnt = 0
  local blink_times = 7
  local timer = uv.new_timer()
  if timer == nil then
    return
  end
  timer:start(
    0,
    100,
    vim.schedule_wrap(function()
      vim.cmd([[
      set cursorcolumn!
      set cursorline!
    ]])
      if cnt == blink_times then
        timer:close()
      end
      cnt = cnt + 1
    end)
  )
end, { desc = "show cursor" })
-- q records macros by accident; use Q instead
keymap.set("n", "q", function()
  vim.print("q is remapped to Q in Normal mode!")
end)
keymap.set("n", "Q", "q", { desc = "record macro" })
keymap.set("n", "<leader>t", "<cmd>ToggleTheme<cr>", { desc = "toggle theme" })
