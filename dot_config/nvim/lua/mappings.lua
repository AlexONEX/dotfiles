local api = vim.api
local uv = vim.loop
local formatters = require("formatters")

function save_and_format()
  vim.cmd("write")
  local ft = vim.bo.filetype
  if ft == "c" or ft == "cpp" or ft == "objc" or ft == "java" or ft == "proto" or ft == "cuda" or ft == "vala" then
    formatters.format_with_clang_format()
  elseif ft == "python" then
    formatters.format_with_black()
  elseif ft == "scala" then
    formatters.format_with_scalafmt()
  elseif ft == "lua" then
    formatters.format_with_stylua()
  elseif ft == "go" then
    formatters.format_with_gofmt()
  elseif ft == "rust" then
    formatters.format_with_rustfmt()
  elseif ft == "javascript" or ft == "typescript" then
    formatters.format_with_eslint()
  elseif ft == "yml" then
    formatters.format_with_prettier()
  elseif ft == "tex" then
    formatters.format_with_latexindent()
  end
  -- Add any additional file type checks here
end
-- Save key strokes (now we do not need to press shift to enter command mode).
vim.keymap.set({ "n", "x" }, ";", ":")

-- Turn the word under cursor to upper case
vim.keymap.set("i", "<c-u>", "<Esc>viwUea")

-- Turn the current word into title case
vim.keymap.set("i", "<c-t>", "<Esc>b~lea")

-- Paste non-linewise text above or below current line, see https://stackoverflow.com/a/1346777/6064933
vim.keymap.set("n", "<leader>p", "m`o<ESC>p``", { desc = "paste below current line" })
vim.keymap.set("n", "<leader>P", "m`O<ESC>p``", { desc = "paste above current line" })

-- Shortcut for faster save and quit
vim.keymap.set("n", "<C-s>", "<cmd>lua save_and_format()<CR>", { silent = true, desc = "save and format file" })
vim.keymap.set("i", "<C-s>", "<Esc><cmd>lua save_and_format()<CR>", { silent = true, desc = "save and format file" })

-- Saves the file if modified and quit
vim.keymap.set(
  "n",
  "q",
  "<cmd>w | if len(getbufinfo({'buflisted':1})) <= 1 | qa | else | bd | endif<CR>",
  { silent = true, desc = "save file, close buffer, or quit nvim" }
)
vim.keymap.set("n", "Q", "<nop>")
-- vim.keymap.set("n", "q", "<cmd>q!<CR>")

-- Quit all opened buffers
vim.keymap.set("n", "<leader>Q", "<cmd>qa!<cr>", { silent = true, desc = "quit nvim" })

-- Navigation in the location and quickfix list
vim.keymap.set("n", "[l", "<cmd>lprevious<cr>zv", { silent = true, desc = "previous location item" })
vim.keymap.set("n", "]l", "<cmd>lnext<cr>zv", { silent = true, desc = "next location item" })

vim.keymap.set("n", "[L", "<cmd>lfirst<cr>zv", { silent = true, desc = "first location item" })
vim.keymap.set("n", "]L", "<cmd>llast<cr>zv", { silent = true, desc = "last location item" })

vim.keymap.set("n", "[q", "<cmd>cprevious<cr>zv", { silent = true, desc = "previous qf item" })
vim.keymap.set("n", "]q", "<cmd>cnext<cr>zv", { silent = true, desc = "next qf item" })

vim.keymap.set("n", "[Q", "<cmd>cfirst<cr>zv", { silent = true, desc = "first qf item" })
vim.keymap.set("n", "]Q", "<cmd>clast<cr>zv", { silent = true, desc = "last qf item" })

-- Close location list or quickfix list if they are present, see https://superuser.com/q/355325/736190
vim.keymap.set("n", [[\x]], "<cmd>windo lclose <bar> cclose <cr>", {
  silent = true,
  desc = "close qf and location list",
})

-- Delete a buffer, without closing the window, see https://stackoverflow.com/q/4465095/6064933
vim.keymap.set("n", [[\d]], "<cmd>bprevious <bar> bdelete #<cr>", {
  silent = true,
  desc = "delete buffer",
})

-- Insert a blank line below or above current line (do not move the cursor),
-- see https://stackoverflow.com/a/16136133/6064933
vim.keymap.set("n", "<leader>o", "printf('m`%so<ESC>``', v:count1)", {
  expr = true,
  desc = "insert line below",
})

vim.keymap.set("n", "<leader>O", "printf('m`%sO<ESC>``', v:count1)", {
  expr = true,
  desc = "insert line above",
})

-- Move the cursor based on physical lines, not the actual lines.
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true })
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true })
vim.keymap.set("n", "^", "g^")
vim.keymap.set("n", "0", "g0")

-- Do not include white space characters when using $ in visual mode,
-- see https://vi.stackexchange.com/q/12607/15292
vim.keymap.set("x", "$", "g_")

-- Go to start or end of line easier
vim.keymap.set({ "n", "x" }, "H", "^")
vim.keymap.set({ "n", "x" }, "0", "^")
vim.keymap.set({ "n", "x" }, "L", "g_")

-- Continuous visual shifting (does not exit Visual mode), `gv` means
-- to reselect previous visual area, see https://superuser.com/q/310432/736190
vim.keymap.set("x", "<", "<gv")
vim.keymap.set("x", ">", ">gv")

-- Disable overwriting when pasting in visual mode
vim.keymap.set("v", "p", '"_dP')

-- Edit and reload nvim config file quickly
vim.keymap.set("n", "<leader>ev", "<cmd>tabnew $MYVIMRC <bar> tcd %:h<cr>", {
  silent = true,
  desc = "open init.lua",
})

vim.keymap.set("n", "<leader>sv", function()
  vim.cmd([[
      update $MYVIMRC
      source $MYVIMRC
    ]])
  vim.notify("Nvim config successfully reloaded!", vim.log.levels.INFO, { title = "nvim-config" })
end, {
  silent = true,
  desc = "reload init.lua",
})

-- Reselect the text that has just been pasted, see also https://stackoverflow.com/a/4317090/6064933.
vim.keymap.set("n", "<leader>v", "printf('`[%s`]', getregtype()[0])", {
  expr = true,
  desc = "reselect last pasted area",
})

-- Always use very magic mode for searching
vim.keymap.set("n", "/", [[/\v]])

-- Search in selected region
-- xnoremap / :<C-U>call feedkeys('/\%>'.(line("'<")-1).'l\%<'.(line("'>")+1)."l")<CR>

-- Change current working directory locally and print cwd after that,
-- see https://vim.fandom.com/wiki/Set_working_directory_to_the_current_file
vim.keymap.set("n", "<leader>cd", "<cmd>lcd %:p:h<cr><cmd>pwd<cr>", { desc = "change cwd" })

-- Use Esc to quit builtin terminal
vim.keymap.set("t", "<Esc>", [[<c-\><c-n>]])

-- Toggle spell checking
vim.keymap.set("n", "<F11>", "<cmd>set spell!<cr>", { desc = "toggle spell" })
vim.keymap.set("i", "<F11>", "<c-o><cmd>set spell!<cr>", { desc = "toggle spell" })

-- Change text without putting it into the vim register,
-- see https://stackoverflow.com/q/54255/6064933
vim.keymap.set("n", "c", '"_c')
vim.keymap.set("n", "C", '"_C')
vim.keymap.set("n", "cc", '"_cc')
vim.keymap.set("x", "c", '"_c')

-- Remove trailing whitespace characters
vim.keymap.set("n", "<leader>,", "<cmd>StripTrailingWhitespace<cr>", { desc = "remove trailing space" })

-- check the syntax group of current cursor position
vim.keymap.set("n", "<leader>st", "<cmd>call utils#SynGroup()<cr>", { desc = "check syntax group" })

-- Copy entire buffer.
vim.keymap.set("n", "<leader>y", "<cmd>%yank<cr>", { desc = "yank entire buffer" })

-- Toggle cursor column
vim.keymap.set("n", "<leader>cl", "<cmd>call utils#ToggleCursorCol()<cr>", { desc = "toggle cursor column" })

-- Move current line up and down
vim.keymap.set("n", "<A-k>", '<cmd>call utils#SwitchLine(line("."), "up")<cr>', { desc = "move line up" })
vim.keymap.set("n", "<A-j>", '<cmd>call utils#SwitchLine(line("."), "down")<cr>', { desc = "move line down" })

-- Move current visual-line selection up and down
vim.keymap.set("x", "<A-k>", '<cmd>call utils#MoveSelection("up")<cr>', { desc = "move selection up" })

vim.keymap.set("x", "<A-j>", '<cmd>call utils#MoveSelection("down")<cr>', { desc = "move selection down" })

-- Replace visual selection with text in register, but not contaminate the register,
-- see also https://stackoverflow.com/q/10723700/6064933.
vim.keymap.set("x", "p", '"_c<Esc>p')

-- Go to a certain buffer
vim.keymap.set("n", "gb", '<cmd>call buf_utils#GoToBuffer(v:count, "forward")<cr>', {
  desc = "go to buffer (forward)",
})
vim.keymap.set("n", "gB", '<cmd>call buf_utils#GoToBuffer(v:count, "backward")<cr>', {
  desc = "go to buffer (backward)",
})

-- Switch windows
vim.keymap.set("n", "<left>", "<c-w>h")
vim.keymap.set("n", "<Right>", "<C-W>l")
vim.keymap.set("n", "<Up>", "<C-W>k")
vim.keymap.set("n", "<Down>", "<C-W>j")

-- Text objects for URL
vim.keymap.set({ "x", "o" }, "iu", "<cmd>call text_obj#URL()<cr>", { desc = "URL text object" })

-- Text objects for entire buffer
vim.keymap.set({ "x", "o" }, "iB", "<cmd>call text_obj#Buffer()<cr>", { desc = "buffer text object" })

-- Do not move my cursor when joining lines.
vim.keymap.set("n", "J", function()
  vim.cmd([[
      normal! mzJ`z
      delmarks z
    ]])
end, {
  desc = "join line",
})

vim.keymap.set("n", "gJ", function()
  -- we must use `normal!`, otherwise it will trigger recursive mapping
  vim.cmd([[
      normal! zmgJ`z
      delmarks z
    ]])
end, {
  desc = "join visual lines",
})

-- Break inserted text into smaller undo units when we insert some punctuation chars.
local undo_ch = { ",", ".", "!", "?", ";", ":" }
for _, ch in ipairs(undo_ch) do
  vim.keymap.set("i", ch, ch .. "<c-g>u")
end

-- insert semicolon in the end
vim.keymap.set("i", "<A-;>", "<Esc>miA;<Esc>`ii")

-- Go to the beginning and end of current line in insert mode quickly
vim.keymap.set("i", "<C-a>", "<HOME>")
vim.keymap.set("i", "<C-e>", "<END>")

-- Go to beginning of command in command-line mode
vim.keymap.set("c", "<C-A>", "<HOME>")

-- Delete the character to the right of the cursor
vim.keymap.set("i", "<C-D>", "<DEL>")

-- Tree Toogle command
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle NvimTree" })

-- Vim tmux navigator
--vim.keymap.set("n", "<C-h>", "<cmd>TmuxNavigateLeft<cr>")
--vim.keymap.set("n", "<C-j>", "<cmd>TmuxNavigateDown<cr>")
--vim.keymap.set("n", "<C-k>", "<cmd>TmuxNavigateUp<cr>")
--vim.keymap.set("n", "<C-l>", "<cmd>TmuxNavigateRight<cr>")

-- Close buffer without losing split
vim.keymap.set("n", "<C-q>", function()
  -- Guardar el archivo actual antes de cerrar
  vim.cmd("write")
  -- Cerrar la ventana actual si hay más de una ventana abierta
  if #vim.api.nvim_tabpage_list_wins(0) > 1 then
    vim.cmd("close")
  -- Cerrar la pestaña actual si hay más de una pestaña abierta
  elseif #vim.api.nvim_list_tabpages() > 1 then
    vim.cmd("tabclose")
  -- Cerrar Neovim si no hay otras ventanas o pestañas
  else
    vim.cmd("qa")
  end
end, { desc = "Super <C-q>" })
vim.keymap.set("n", "<leader>w", "<cmd>bp|bd #<CR>", { desc = "Close Buffer; Retain Split" })

-- Copy filename to clipboard
vim.keymap.set("n", "<leader>cf", '<cmd>let @+ = expand("%")<CR>', { desc = "Copy File Name" })

-- Copy file path to clipboard
vim.keymap.set("n", "<leader>cp", '<cmd>let @+ = expand("%:p")<CR>', { desc = "Copy File Path" })

-- Mapeo para ejecutar HopWord con Ctrl+f
vim.keymap.set("n", "<C-f>", ":HopWord<CR>", { silent = true, desc = "HopWord" })
vim.keymap.set("v", "<C-f>", ":HopWord<CR>", { silent = true, desc = "HopWord" })
vim.keymap.set("i", "<C-f>", "<Esc>:HopWord<CR>", { silent = true, desc = "HopWord" })

-- Mapeo para ejecutar HopLine con Ctrl+l
vim.keymap.set("n", "<C-l>", ":HopLine<CR>", { silent = true, desc = "HopLine" })
vim.keymap.set("v", "<C-l>", ":HopLine<CR>", { silent = true, desc = "HopLine" })
vim.keymap.set("i", "<C-l>", "<Esc>:HopLine<CR>", { silent = true, desc = "HopLine" })
