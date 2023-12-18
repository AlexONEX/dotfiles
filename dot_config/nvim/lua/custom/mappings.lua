---@type MappingsTable
local M = {}

-- General keybindings
M.general = {
  n = {
    [";"] = { ":", "enter command mode", opts = { nowait = true } },
    ["<leader>sv"] = {
      function()
        vim.cmd [[
          update $MYVIMRC
          source $MYVIMRC
        ]]
        vim.notify("Nvim config successfully reloaded!", vim.log.levels.INFO, { title = "nvim-config" })
      end,
      "reload init.lua",
    },
    ["<leader>cd"] = { "<cmd>lcd %:p:h<cr><cmd>pwd<cr>", "change cwd" },
    ["<leader>e"] = { ":NvimTreeToggle<CR>", "Toggle NvimTree" },
    ["<leader>cf"] = { '<cmd>let @+ = expand("%")<CR>', "Copy File Name" },
    ["<leader>cp"] = { '<cmd>let @+ = expand("%:p")<CR>', "Copy File Path" },
    ["<leader>y"] = { "<cmd>%yank<cr>", "yank entire buffer" },
    ["<leader>cl"] = { "<cmd>call utils#ToggleCursorCol()<cr>", "toggle cursor column" },
    ["<A-k>"] = { '<cmd>call utils#SwitchLine(line("."), "up")<cr>', "move line up" },
    ["<A-j>"] = { '<cmd>call utils#SwitchLine(line("."), "down")<cr>', "move line down" },
    ["<C-f>"] = { ":HopWord<CR>", "HopWord", silent = true },
    ["<C-l>"] = { ":HopLine<CR>", "HopLine", silent = true },
    ["<F11>"] = { "<cmd>set spell!<cr>", "toggle spell" },
    ["q"] = {
      "<cmd>w | if len(getbufinfo({'buflisted':1})) <= 1 | qa | else | bd | endif<CR>",
      "save file, close buffer, or quit nvim",
      silent = true,
    },
    ["/"] = { [[/\v]], "very magic mode for searching" },
    ["H"] = { "^", "start of line" },
    ["0"] = { "^", "start of line" },
    ["L"] = { "g_", "end of line" },
    ["J"] = {
      function()
        vim.cmd [[
          normal! mzJ`z
          delmarks z
        ]]
      end,
      "join line",
    },
    ["gJ"] = {
      function()
        vim.cmd [[
          normal! zmgJ`z
          delmarks z
        ]]
      end,
      "join visual lines",
    },
  },
  
  v = {
    [">"] = { ">gv", "indent" },
    ["<"] = { "<gv", "unindent" },
    ["p"] = { '"_c<Esc>p', "paste without yanking" },
    ["<A-k>"] = { '<cmd>call utils#MoveSelection("up")<cr>', "move selection up" },
    ["<A-j>"] = { '<cmd>call utils#MoveSelection("down")<cr>', "move selection down" },
  },
  x = {
    -- Insert additional visual mode keybindings here
  },
  i = {
    ["<c-u>"] = { "<Esc>viwUea", "uppercase word" },
    ["<c-t>"] = { "<Esc>b~lea", "title case word" },
    ["<A-;>"] = { "<Esc>miA;<Esc>`ii", "insert semicolon at end" },
    ["<C-b>"] = { "<HOME>", "beginning of line" },
    ["<C-e>"] = { "<END>", "end of line" },
    ["<C-D>"] = { "<DEL>", "delete char right" },
  },
  c = {
    ["<C-A>"] = { "<HOME>", "beginning of command" },
  },
  t = {
    ["<Esc>"] = { [[<c-\><c-n>]], "escape terminal mode" },
  },
}

-- Adding keybindings for punctuation undo
local undo_ch = { ",", ".", "!", "?", ";", ":" }
for _, ch in ipairs(undo_ch) do
  M.general.i[ch] = { ch .. "<c-g>u", "undo point for punctuation" }
end

return M
