local M = {}

function M.setup()
	-- Set viewer method
	vim.g.vimtex_view_method = "zathura"

	-- Configure compiler method
	vim.g.vimtex_compiler_method = "latexmk"

	-- Compiler configuration
	vim.g.vimtex_compiler_latexmk = {
		build_dir = "",
		callback = 1,
		continuous = 1,
		executable = "latexmk",
		hooks = {},
		options = {
			"-verbose",
			"-file-line-error",
			"-synctex=1",
			"-interaction=nonstopmode",
		},
	}

	-- General settings
	vim.g.vimtex_quickfix_mode = 0
	vim.g.vimtex_quickfix_enabled = 1
	vim.g.vimtex_syntax_enabled = 1
	vim.g.tex_flavor = "latex"
	vim.g.tex_conceal = "abdmg"
	vim.opt.conceallevel = 2

	-- Disable default mappings
	vim.g.vimtex_mappings_enabled = 1
	vim.g.vimtex_mappings_disable = { ["n"] = { "K" } }

	-- Enable imaps (inline math)
	vim.g.vimtex_imaps_enabled = 1

	-- PDF viewer settings for forward search
	vim.g.vimtex_view_general_viewer = "zathura"
	vim.g.vimtex_view_general_options = [[--unique file:@pdf\#src:@line@tex]]
end

return M
