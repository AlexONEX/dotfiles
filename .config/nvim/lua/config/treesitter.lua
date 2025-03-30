require("nvim-treesitter.configs").setup({
	ensure_installed = {
		"python",
		"cpp",
		"lua",
		"vim",
		"json",
		"toml",
		"latex",
		"sql",
		"bibtex",
		"markdown",
		"markdown_inline",
		"haskell",
	},
	ignore_install = {}, -- List of parsers to ignore installing
	sync_install = false,
	auto_install = true,
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
})
