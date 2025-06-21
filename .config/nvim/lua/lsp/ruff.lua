return {
	cmd = { "ruff", "server", "--preview" },
	filetypes = { "python" },
	root_markers = {
		"pyproject.toml",
		"ruff.toml",
		".ruff.toml",
		"setup.py",
		".git",
	},
	init_options = {
		settings = {
			args = {},
		},
	},
	settings = {
		organizeImports = true,
		fixAll = true,
	},
}
