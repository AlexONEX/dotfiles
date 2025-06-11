return {
	cmd = { "haskell-language-server-wrapper", "--lsp" },
	filetypes = { "haskell", "lhaskell" },
	root_markers = {
		"*.cabal",
		"stack.yaml",
		"cabal.project",
		"package.yaml",
		"hie.yaml",
		".git",
	},
	settings = {
		haskell = {
			cabalFormattingProvider = "cabalfmt",
			formattingProvider = "ormolu",
		},
	},
}
