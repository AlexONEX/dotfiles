return {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	root_markers = { { ".luarc.json", ".luarc.jsonc" }, ".git" },
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
			},
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
				checkThirdParty = false,
			},
			telemetry = {
				enable = false,
			},
			hint = {
				enable = true,
				paramType = true,
				paramName = "Disable", -- "All" | "Literal" | "Disable"
				semicolon = "Disable", -- "All" | "SameLine" | "Disable"
				arrayIndex = "Disable", -- "Auto" | "Enable" | "Disable"
			},
			format = {
				enable = false,
			},
			completion = {
				callSnippet = "Replace",
			},
		},
	},
}
