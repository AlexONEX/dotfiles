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

keymap.set("n", "<leader>ef", "<cmd>Telescope find_files<cr>", { desc = "Find files in current directory" })
keymap.set("n", "<leader>eg", "<cmd>Telescope live_grep<cr>", { desc = "Find text in current directory" })
keymap.set("n", "<leader>eb", "<cmd>Telescope buffers<cr>", { desc = "Find buffers" })
keymap.set("n", "<leader>eh", "<cmd>Telescope help_tags<cr>", { desc = "Find help tags" })
keymap.set("n", "<leader>ec", "<cmd>Telescope current_buffer_fuzzy_find<cr>", { desc = "Find text in current file" })
keymap.set("n", "<leader>er", "<cmd>Telescope oldfiles<cr>", { desc = "Find recent files" })
keymap.set("n", "<leader>em", "<cmd>Telescope marks<cr>", { desc = "Find marks" })
keymap.set("n", "<leader>ek", "<cmd>Telescope keymaps<cr>", { desc = "Find keymaps" })

keymap.set("n", "<leader>tg", "<cmd>Telescope git_files<cr>", { desc = "Find files in git project" })
keymap.set("n", "<leader>ts", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor" })
keymap.set("n", "<leader>tc", "<cmd>Telescope commands<cr>", { desc = "Find and execute commands" })
keymap.set("n", "<leader>tr", "<cmd>Telescope registers<cr>", { desc = "Find registers" })
keymap.set("n", "<leader>tt", "<cmd>Telescope treesitter<cr>", { desc = "Find treesitter symbols" })
keymap.set("n", "<leader>tq", "<cmd>Telescope quickfix<cr>", { desc = "Find quickfix entries" })
keymap.set("n", "<leader>tl", "<cmd>Telescope loclist<cr>", { desc = "Find loclist entries" })
keymap.set("n", "<leader>td", "<cmd>Telescope diagnostics<cr>", { desc = "Find diagnostics" })
