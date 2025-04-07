local fn = vim.fn
local api = vim.api
local keymap = vim.keymap
local lsp = vim.lsp
local diagnostic = vim.diagnostic
local lspconfig = require("lspconfig")
local typescript_tools = require("typescript-tools")

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
      keymap.set(mode, l, r, opts)
    end

    map("n", "gd", vim.lsp.buf.definition, { desc = "go to definition" })
    map("n", "<C-]>", vim.lsp.buf.definition)
    map("n", "K", function()
      vim.lsp.buf.hover { border = "single", max_height = 25, max_width = 120 }
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
      local gid = api.nvim_create_augroup("lsp_document_highlight", { clear = true })
      api.nvim_create_autocmd("CursorHold", {
        group = gid,
        buffer = bufnr,
        callback = function()
          lsp.buf.document_highlight()
        end,
      })

      api.nvim_create_autocmd("CursorMoved", {
        group = gid,
        buffer = bufnr,
        callback = function()
          lsp.buf.clear_references()
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

-- For what diagnostic is enabled in which type checking mode, check doc:
-- https://github.com/microsoft/pyright/blob/main/docs/configuration.md#diagnostic-settings-defaults
-- Currently, the pyright also has some issues displaying hover documentation:
-- https://www.reddit.com/r/neovim/comments/1gdv1rc/what_is_causeing_the_lsp_hover_docs_to_looks_like/

if utils.executable("pyright") then
  local new_capability = {
    -- this will remove some of the diagnostics that duplicates those from ruff, idea taken and adapted from
    -- here: https://github.com/astral-sh/ruff-lsp/issues/384#issuecomment-1989619482
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

  lspconfig.pyright.setup {
    --cmd = { "delance-langserver", "--stdio" },
    capabilities = merged_capability,
    pyright = {
      -- disable import sorting and use Ruff for this
      disableOrganizeImports = true,
      disableTaggedHints = false,
    },
    python = {
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = "workspace",
        typeCheckingMode = "standard",
        useLibraryCodeForTypes = true,
        -- we can this setting below to redefine some diagnostics
        diagnosticSeverityOverrides = {
          deprecateTypingAliases = false,
        },
        -- inlay hint settings are provided by pylance?
        inlayHints = {
          callArgumentNames = "partial",
          functionReturnTypes = true,
          pytestParameters = true,
          variableTypes = true,
        },
      },
    },
  }
else
  vim.notify("pyright not found!", vim.log.levels.WARN, { title = "Nvim-config" })
end

if utils.executable("ruff") then
  require("lspconfig").ruff.setup {
    capabilities = capabilities,
    init_options = {
      -- the settings can be found here: https://docs.astral.sh/ruff/editors/settings/
      settings = {
        organizeImports = true,
      },
    },
  }
end

if utils.executable("ltex-ls") then
  lspconfig.ltex.setup {
    cmd = { "ltex-ls" },
    filetypes = { "text", "plaintex", "tex", "markdown" },
    settings = {
      ltex = {
        language = "en",
      },
    },
    flags = { debounce_text_changes = 300 },
  }
end

if utils.executable("clangd") then
  lspconfig.clangd.setup {
    capabilities = capabilities,
    filetypes = { "c", "cpp", "cc" },
    flags = {
      debounce_text_changes = 500,
    },
  }
end

-- set up bash-language-server
if utils.executable("bash-language-server") then
  lspconfig.bashls.setup {
    capabilities = capabilities,
    filetypes = { "sh", "bash", "zsh" },
  }
end

-- settings for lua-language-server can be found on https://luals.github.io/wiki/settings/
if utils.executable("lua-language-server") then
  -- settings for lua-language-server can be found on https://github.com/LuaLS/lua-language-server/wiki/Settings .
  lspconfig.lua_ls.setup {
    capabilities = capabilities,
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
        format = {
          enable = true,
          defaultConfig = {
            indent_style = "space",
            indent_size = "2",
          },
        },
      },
    },
    -- Agregar soporte para archivos Vim
    filetypes = { "lua", "vim" },
    single_file_support = true,
    flags = {
      debounce_text_changes = 500,
    },
  }
else
  vim.notify("lua-language-server not found!", vim.log.levels.WARN, { title = "Nvim-config" })
end

if utils.executable("rust-analyzer") then
  lspconfig.rust_analyzer.setup {
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
  }
else
  vim.notify("rust-analyzer not found!", vim.log.levels.WARN, { title = "Nvim-config" })
end

if utils.executable("typescript-language-server") then
  typescript_tools.setup {
    on_attach = function(client, bufnr)
      custom_attach(client, bufnr)

      local map = function(mode, l, r, opts)
        opts = opts or {}
        opts.silent = true
        opts.buffer = bufnr
        keymap.set(mode, l, r, opts)
      end

      -- TypeScript specific mappings
      map("n", "<leader>to", ":TSToolsOrganizeImports<CR>", { desc = "organize imports" })
      map("n", "<leader>ts", ":TSToolsSortImports<CR>", { desc = "sort imports" })
      map("n", "<leader>tu", ":TSToolsRemoveUnused<CR>", { desc = "remove unused" })
      map("n", "<leader>ta", ":TSToolsAddMissingImports<CR>", { desc = "add missing imports" })
      map("n", "<leader>tf", ":TSToolsFixAll<CR>", { desc = "fix all" })
      map("n", "<leader>tg", ":TSToolsGoToSourceDefinition<CR>", { desc = "go to source definition" })
      map("n", "<leader>tr", ":TSToolsFileReferences<CR>", { desc = "find file references" })
      map("n", "<leader>tR", ":TSToolsRenameFile<CR>", { desc = "rename file" })
    end,
    capabilities = capabilities,
    settings = {
      -- Enhanced settings for better TypeScript support
      separate_diagnostic_server = true,
      publish_diagnostic_on = "insert_leave",
      expose_as_code_action = {
        "fix_all",
        "add_missing_imports",
        "remove_unused",
        "remove_unused_imports",
        "organize_imports",
      },
      tsserver_file_preferences = {
        includeInlayParameterNameHints = "all",
        includeInlayEnumMemberValueHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeCompletionsForModuleExports = true,
        quotePreference = "single",
      },
      tsserver_format_options = {
        allowIncompleteCompletions = false,
        allowRenameOfImportPath = false,
        convertTabsToSpaces = true,
        indentSize = 2,
        tabSize = 2,
      },
      -- Use 'auto' for automatic memory management based on system resources
      tsserver_max_memory = "auto",
    },
  }
else
  vim.notify("typescript-language-server not found!", vim.log.levels.WARN, { title = "Nvim-config" })
end

if utils.executable("haskell-language-server-wrapper") then
  lspconfig.hls.setup {
    on_attach = custom_attach,
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
  }
else
  vim.notify("haskell-language-server-wrapper not found!", vim.log.levels.WARN, { title = "Nvim-config" })
end

-- global config for diagnostic
diagnostic.config {
  underline = false,
  virtual_text = false,
  virtual_lines = false,
  signs = {
    text = {
      [diagnostic.severity.ERROR] = "🆇",
      [diagnostic.severity.WARN] = "⚠️",
      [diagnostic.severity.INFO] = "ℹ️",
      [diagnostic.severity.HINT] = "",
    },
  },
  severity_sort = true,
  float = {
    source = true,
    header = "Diagnostics:",
    prefix = " ",
    border = "single",
  },
}

api.nvim_create_autocmd("CursorHold", {
  pattern = "*",
  callback = function()
    if #vim.diagnostic.get(0) == 0 then
      return
    end

    if not vim.b.diagnostics_pos then
      vim.b.diagnostics_pos = { nil, nil }
    end

    local cursor_pos = api.nvim_win_get_cursor(0)
    if cursor_pos[1] ~= vim.b.diagnostics_pos[1] or cursor_pos[2] ~= vim.b.diagnostics_pos[2] then
      diagnostic.open_float()
    end

    vim.b.diagnostics_pos = cursor_pos
  end,
})
