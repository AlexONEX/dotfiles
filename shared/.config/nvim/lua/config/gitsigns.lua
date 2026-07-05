local gs = require("gitsigns")

gs.setup({
	signs = {
		add = { text = "+" },
		change = { text = "~" },
		delete = { text = "_" },
		topdelete = { text = "‾" },
		changedelete = { text = "│" },
	},
	word_diff = false,
	on_attach = function(bufnr)
		local function map(mode, l, r, opts)
			opts = opts or {}
			opts.buffer = bufnr
			vim.keymap.set(mode, l, r, opts)
		end

		-- Navigation
		map("n", "]g", function()
			if vim.wo.diff then
				return "]g"
			end
			vim.schedule(function()
				gs.next_hunk()
			end)
			return "<Ignore>"
		end, { expr = true, desc = "next hunk" })

		map("n", "[g", function()
			if vim.wo.diff then
				return "[g"
			end
			vim.schedule(function()
				gs.prev_hunk()
			end)
			return "<Ignore>"
		end, { expr = true, desc = "previous hunk" })

		-- Actions
		map("n", "<leader>gs", gs.stage_hunk, { desc = "stage hunk" })
		map("n", "<leader>gr", gs.reset_hunk, { desc = "reset hunk" })
		map("v", "<leader>gs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { desc = "stage hunk" })
		map("v", "<leader>gr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { desc = "reset hunk" })
		map("n", "<leader>gS", gs.stage_buffer, { desc = "stage buffer" })
		map("n", "<leader>gu", gs.undo_stage_hunk, { desc = "undo stage hunk" })
		map("n", "<leader>gd", gs.diffthis, { desc = "diff this" })
		map("n", "<leader>gp", gs.preview_hunk, { desc = "preview hunk" })
		map("n", "<leader>gb", function()
			gs.blame_line({ full = true })
		end, { desc = "blame line" })
	end,
})

vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = "*",
	callback = function()
		vim.cmd([[
      hi GitSignsChangeInline gui=reverse
      hi GitSignsAddInline gui=reverse
      hi GitSignsDeleteInline gui=reverse
    ]])
	end,
})
