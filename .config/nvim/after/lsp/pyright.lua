local lsp_utils = require("lsp_utils")

-- Additional Pyright-specific capabilities
local pyright_capability = {
	textDocument = {
		publishDiagnostics = {
			tagSupport = {
				valueSet = { 2 },
			},
		},
		hover = {
			contentFormat = { "plaintext" },
			dynamicRegistration = true,
		},
	},
}

local capabilities = vim.tbl_deep_extend("force", lsp_utils.get_default_capabilities(), pyright_capability)

return {
	cmd = { "pyright-langserver", "--stdio" },
	capabilities = capabilities,
	settings = {
		pyright = {
			disableOrganizeImports = true,
			disableTaggedHints = false,
		},
		python = {
			analysis = {
				autoSearchPaths = true,
				diagnosticMode = "workspace",
				typeCheckingMode = "standard",
				useLibraryCodeForTypes = true,
				diagnosticSeverityOverrides = {
					deprecateTypingAliases = false,
				},
				inlayHints = {
					callArgumentNames = "partial",
					functionReturnTypes = true,
					pytestParameters = true,
					variableTypes = true,
				},
			},
		},
	},
}
