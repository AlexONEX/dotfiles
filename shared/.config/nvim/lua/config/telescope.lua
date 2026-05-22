local telescope = require("telescope")
local actions = require("telescope.actions")
local keymap = vim.keymap

telescope.setup({
	defaults = {
		mappings = {
			i = {
				["<C-j>"] = actions.move_selection_next,
				["<C-k>"] = actions.move_selection_previous,
			},
		},
	},
})


