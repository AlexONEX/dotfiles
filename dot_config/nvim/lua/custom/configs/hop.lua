local keymap = vim.keymap
local hop = require "hop"
hop.setup {
  case_insensitive = true,
  char2_fallback_key = "<CR>",
  quit_key = "<Esc>",
}
--     ["<C-f>"] = { ":HopWord<CR>", "HopWord", silent = true },
--     ["<C-l>"] = { ":HopLine<CR>", "HopLine", silent = true },
