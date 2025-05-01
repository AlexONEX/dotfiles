-- after/lsp/hls.lua
local lsp_utils = require("lsp_utils")

return {
	capabilities = lsp_utils.get_default_capabilities(),
	filetypes = { "haskell", "lhaskell" },
	settings = {
		haskell = {
			formattingProvider = "fourmolu",
			plugin = {
				stan = { globalOn = true },
				hlint = { globalOn = true },
				haddockComments = { globalOn = true },
				class = { globalOn = true },
				retrie = { globalOn = true },
				rename = { globalOn = true },
				importLens = { globalOn = true },
				alternateNumberFormat = { globalOn = true },
				eval = { globalOn = true },
			},
		},
	},
}
