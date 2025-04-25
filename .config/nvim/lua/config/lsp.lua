local utils = require("utils")
local diagnostic = vim.diagnostic

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("buf_behavior_conf", { clear = true }),
	callback = function(event_context)
		local client = vim.lsp.get_client_by_id(event_context.data.client_id)
		-- vim.print(client.name, client.server_capabilities)

		if not client then
			return
		end

		local bufnr = event_context.buf

		-- Mappings.
		local map = function(mode, l, r, opts)
			opts = opts or {}
			opts.silent = true
			opts.buffer = bufnr
			vim.keymap.set(mode, l, r, opts)
		end

		map("n", "gd", vim.lsp.buf.definition, { desc = "go to definition" })
		map("n", "<C-]>", vim.lsp.buf.definition)
		map("n", "K", function()
			vim.lsp.buf.hover({ border = "single", max_height = 25, max_width = 120 })
		end)
		map("n", "<C-k>", vim.lsp.buf.signature_help)
		map("n", "<space>rn", vim.lsp.buf.rename, { desc = "varialbe rename" })
		map("n", "<space>ca", vim.lsp.buf.code_action, { desc = "LSP code action" })
		map("n", "<space>wa", vim.lsp.buf.add_workspace_folder, { desc = "add workspace folder" })
		map("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, { desc = "remove workspace folder" })
		map("n", "<space>wl", function()
			vim.print(vim.lsp.buf.list_workspace_folders())
		end, { desc = "list workspace folder" })

		-- Set some key bindings conditional on server capabilities
		if client.server_capabilities.documentFormattingProvider and client.name ~= "lua_ls" then
			map({ "n", "x" }, "<space>f", vim.lsp.buf.format, { desc = "format code" })
		end

		-- Disable ruff hover feature in favor of Pyright
		if client.name == "ruff" then
			client.server_capabilities.hoverProvider = false
		end

		-- Uncomment code below to enable inlay hint from language server, some LSP server supports inlay hint,
		-- but disable this feature by default, so you may need to enable inlay hint in the LSP server config.
		-- vim.lsp.inlay_hint.enable(true, {buffer=bufnr})

		-- The blow command will highlight the current variable and its usages in the buffer.
		if client.server_capabilities.documentHighlightProvider then
			local gid = vim.api.nvim_create_augroup("lsp_document_highlight", { clear = true })
			vim.api.nvim_create_autocmd("CursorHold", {
				group = gid,
				buffer = bufnr,
				callback = function()
					vim.lsp.buf.document_highlight()
				end,
			})

			vim.api.nvim_create_autocmd("CursorMoved", {
				group = gid,
				buffer = bufnr,
				callback = function()
					vim.lsp.buf.clear_references()
				end,
			})
		end
	end,
	nested = true,
	desc = "Configure buffer keymap and behavior based on LSP",
})

local capabilities = vim.lsp.protocol.make_client_capabilities()

-- required by nvim-ufo
capabilities.textDocument.foldingRange = {
	dynamicRegistration = false,
	lineFoldingOnly = true,
}

-- Pyright configuration
if utils.executable("pyright") then
	local new_capability = {
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
	local merged_capability = vim.tbl_deep_extend("force", capabilities, new_capability)

	vim.lsp.config("pyright", {
		cmd = { "pyright-langserver", "--stdio" },
		capabilities = merged_capability,
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
	})

	vim.lsp.enable("pyright")
else
	vim.notify("pyright not found!", vim.log.levels.WARN, { title = "Nvim-config" })
end

-- Ruff configuration
if utils.executable("ruff") then
	vim.lsp.config("ruff", {
		capabilities = capabilities,
		init_options = {
			settings = {
				organizeImports = true,
			},
		},
	})
	vim.lsp.enable("ruff")
end

-- LTEX configuration
if utils.executable("ltex-ls") then
	vim.lsp.config("ltex", {
		filetypes = { "text", "plaintex", "tex", "markdown" },
		settings = {
			ltex = {
				language = "en",
			},
		},
		flags = { debounce_text_changes = 300 },
	})

	vim.lsp.enable("ltex")
end

-- Clangd configuration
if utils.executable("clangd") then
	vim.lsp.config("clangd", {
		capabilities = capabilities,
		filetypes = { "c", "cpp", "cc" },
		flags = {
			debounce_text_changes = 500,
		},
	})

	vim.lsp.enable("clangd")
end

-- Vim language server
if utils.executable("vim-language-server") then
	vim.lsp.config("vimls", {
		flags = {
			debounce_text_changes = 500,
		},
		capabilities = capabilities,
	})

	vim.lsp.enable("vimls")
else
	vim.notify("vim-language-server not found!", vim.log.levels.WARN, { title = "Nvim-config" })
end

-- Bash language server
if utils.executable("bash-language-server") then
	vim.lsp.config("bashls", {
		capabilities = capabilities,
		filetypes = { "sh", "bash", "zsh" },
	})

	vim.lsp.enable("bashls")
end

-- Lua language server
if utils.executable("lua-language-server") then
	vim.lsp.config("lua_ls", {
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
				},
				format = {
					enable = true,
					defaultConfig = {
						indent_style = "space",
						indent_size = "2",
					},
				},
			},
		},
		capabilities = capabilities,
		filetypes = { "lua", "vim" },
		single_file_support = true,
		flags = {
			debounce_text_changes = 500,
		},
	})

	vim.lsp.enable("lua_ls")
else
	vim.notify("lua-language-server not found!", vim.log.levels.WARN, { title = "Nvim-config" })
end

-- Rust analyzer
if utils.executable("rust-analyzer") then
	vim.lsp.config("rust_analyzer", {
		capabilities = capabilities,
		settings = {
			["rust-analyzer"] = {
				assist = {
					importGranularity = "module",
					importPrefix = "self",
				},
				cargo = {
					loadOutDirsFromCheck = true,
					buildScripts = {
						enable = true,
					},
				},
				procMacro = {
					enable = true,
				},
			},
		},
	})

	vim.lsp.enable("rust_analyzer")
else
	vim.notify("rust-analyzer not found!", vim.log.levels.WARN, { title = "Nvim-config" })
end

-- Haskell language server
if utils.executable("haskell-language-server-wrapper") then
	vim.lsp.config("hls", {
		capabilities = capabilities,
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
	})

	vim.lsp.enable("hls")
else
	vim.notify("haskell-language-server-wrapper not found!", vim.log.levels.WARN, { title = "Nvim-config" })
end

-- Global diagnostic configuration
diagnostic.config({
	underline = false,
	virtual_text = false,
	virtual_lines = false,
	signs = {
		text = {
			[diagnostic.severity.ERROR] = "🆇",
			[diagnostic.severity.WARN] = "⚠️",
			[diagnostic.severity.INFO] = "ℹ️",
			[diagnostic.severity.HINT] = "",
		},
	},
	severity_sort = true,
	float = {
		source = true,
		header = "Diagnostics:",
		prefix = " ",
		border = "single",
	},
})

-- Show diagnostics on cursor hold
vim.api.nvim_create_autocmd("CursorHold", {
	pattern = "*",
	callback = function()
		if #vim.diagnostic.get(0) == 0 then
			return
		end

		if not vim.b.diagnostics_pos then
			vim.b.diagnostics_pos = { nil, nil }
		end

		local cursor_pos = vim.api.nvim_win_get_cursor(0)
		if cursor_pos[1] ~= vim.b.diagnostics_pos[1] or cursor_pos[2] ~= vim.b.diagnostics_pos[2] then
			diagnostic.open_float()
		end

		vim.b.diagnostics_pos = cursor_pos
	end,
})
