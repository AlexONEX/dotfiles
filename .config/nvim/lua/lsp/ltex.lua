return {
	cmd = { "ltex-ls" },
	filetypes = { "bib", "gitcommit", "markdown", "org", "plaintex", "rst", "rnoweb", "tex", "pandoc" },
	root_markers = { ".git", "." },
	settings = {
		ltex = {
			language = "auto",
			dictionary = {},
			disabledRules = {},
			hiddenFalsePositives = {},
			latex = {
				commands = {},
				environments = {},
			},
			markdown = {
				nodes = {},
			},
		},
	},
}
