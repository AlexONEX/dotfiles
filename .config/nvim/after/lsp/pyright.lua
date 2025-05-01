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

return {
	cmd = { "pyright-langserver", "--stdio" },
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
