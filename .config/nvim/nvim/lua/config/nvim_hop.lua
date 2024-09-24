local keymap = vim.keymap
local hop = require("hop")
hop.setup({
	case_insensitive = true,
	char2_fallback_key = "",
	quit_key = "",
	match_mappings = { "zh_sc" },
})

keymap.set({ "n", "v", "o" }, "<C-l>", "", {
	silent = true,
	noremap = true,
	callback = function()
		hop.hint_lines()
	end,
	desc = "nvim-hop char",
})

keymap.set({ "n", "v", "o" }, "<C-d>", "", {
	silent = true,
	noremap = true,
	callback = function()
		hop.hint_words()
	end,
	desc = "nvim-hop words",
})

vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = "*",
	callback = function()
		vim.cmd([[
      hi HopNextKey cterm=bold ctermfg=176 gui=bold guibg=#ff00ff guifg=#ffffff
      hi HopNextKey1 cterm=bold ctermfg=176 gui=bold guibg=#ff00ff guifg=#ffffff
      hi HopNextKey2 cterm=bold ctermfg=176 gui=bold guibg=#ff00ff guifg=#ffffff
    ]])
	end,
})
