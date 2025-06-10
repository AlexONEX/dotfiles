vim.opt_local.textwidth = 120
vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.formatoptions:remove({ "o", "r" })
vim.opt_local.expandtab = true
vim.opt_local.shiftwidth = 2
vim.opt_local.tabstop = 2
vim.opt_local.softtabstop = 2
vim.opt_local.spell = true
vim.opt_local.spelllang = "es,en"
vim.opt_local.conceallevel = 2
vim.opt_local.concealcursor = "nc"

local M = {}

local function disable_treesitter()
	if vim.fn.exists(":TSBufDisable") == 2 then
		vim.cmd("TSBufDisable highlight")
	else
		vim.defer_fn(function()
			if vim.fn.exists(":TSBufDisable") == 2 then
				vim.cmd("TSBufDisable highlight")
			end
		end, 500)
	end
end

function M.format_and_save()
	vim.lsp.buf.format()
	vim.cmd("write")
end

function M.toggle_concealment()
	local current_level = vim.api.nvim_get_option_value("conceallevel", { scope = "local" })
	if current_level == 0 then
		vim.api.nvim_set_option_value("conceallevel", 2, { scope = "local" })
		vim.notify("Concealment enabled")
	else
		vim.api.nvim_set_option_value("conceallevel", 0, { scope = "local" })
		vim.notify("Concealment disabled")
	end
end

_G.Ftplugin_Tex = M

if vim.fn.filereadable(vim.fn.stdpath("config") .. "/lua/config/vimtex.lua") then
	local vimtex_config = require("config.vimtex")
	vimtex_config.setup()
end

vim.defer_fn(disable_treesitter, 100)

vim.keymap.set("i", "<A-l>", "<c-g>u<Esc>[s1z=`]a<c-g>u", { noremap = true, silent = true, buffer = true })
vim.keymap.set("n", "<C-s>", ":lua Ftplugin_Tex.format_and_save()<CR>", { buffer = true, silent = true })
vim.keymap.set("n", "<leader>lh", ":lua Ftplugin_Tex.toggle_concealment()<CR>", { buffer = true, silent = true })
vim.keymap.set("i", ";;", "\\", { buffer = true })
vim.keymap.set("i", "$$", "$$ $$<left><left><left>", { buffer = true })

vim.api.nvim_buf_create_user_command(0, "FormatAndSaveLatex", function()
	M.format_and_save()
end, { desc = "Format and save LaTeX file" })
