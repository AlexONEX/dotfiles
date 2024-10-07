require("nvim-treesitter.configs").setup({
	ensure_installed = {
		"python",
		"cpp",
		"lua",
		"vim",
		"json",
		"toml",
		"latex", -- Para archivos LaTeX
		"sql", -- Para archivos SQL
		"bibtex", -- Útil para referencias en LaTeX
		"markdown", -- Útil para documentación y comentarios
		"markdown_inline", -- Para mejor soporte de Markdown
	},
	ignore_install = {}, -- List of parsers to ignore installing
	sync_install = false,
	auto_install = true,
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
})
