local utils = require("utils")
local lsp_utils = require("lsp_utils")

vim.lsp.config("*", {
  capabilities = lsp_utils.get_default_capabilities(),
  flags = {
    debounce_text_changes = 500,
    allow_incremental_sync = true,
  },
  root_markers = { ".git" },
})

local enabled_lsp_servers = {
  bashls = "bash-language-server",
  clangd = "clangd",
  hls = "haskell-language-server-wrapper",
  ltex = "ltex-ls",
  lua_ls = "lua-language-server",
  pyright = "pyright-langserver",
  ruff = "ruff",
  rust_analyzer = "rust-analyzer",
  texlab = "texlab",
  vimls = "vim-language-server",
  yamlls = "yaml-language-server",
}

for server_name, lsp_executable in pairs(enabled_lsp_servers) do
  if utils.executable(lsp_executable) then
    vim.lsp.enable(server_name)
  else
    local msg = string.format(
      "Executable '%s' for server '%s' not found! Server will not be enabled",
      lsp_executable,
      server_name
    )
    vim.notify(msg, vim.log.levels.WARN, { title = "Nvim-config" })
  end
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp_buf_conf", { clear = true }),
  callback = function(event_context)
    local client = vim.lsp.get_client_by_id(event_context.data.client_id)
    if not client then
      return
    end

    local bufnr = event_context.buf

    local map = function(mode, l, r, opts)
      opts = opts or {}
      opts.silent = true
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    map("n", "gd", function()
      vim.lsp.buf.definition {
        on_list = function(options)
          local unique_defs = {}
          local def_loc_hash = {}

          for _, def_location in pairs(options.items) do
            local hash_key = def_location.filename .. def_location.lnum
            if not def_loc_hash[hash_key] then
              def_loc_hash[hash_key] = true
              table.insert(unique_defs, def_location)
            end
          end

          options.items = unique_defs
          vim.fn.setloclist(0, {}, " ", options)

          if #options.items > 1 then
            vim.cmd.lopen()
          else
            vim.cmd([[silent! lfirst]])
          end
        end,
      }
    end, { desc = "LSP: Go to definition" })

    map("n", "<C-]>", vim.lsp.buf.definition, { desc = "LSP: Go to definition (quick)" })

    map("n", "K", function()
      vim.lsp.buf.hover {
        border = "single",
        max_height = 25,
        max_width = 120,
      }
    end, { desc = "LSP: Show hover information" })

    map("n", "<space>K", function()
      local params = vim.lsp.util.make_position_params()
      vim.lsp.buf_request(0, "textDocument/hover", params, function(err, result, ctx, config)
        if err or not result or not result.contents then
          vim.notify("No hover information available", vim.log.levels.INFO)
          return
        end

        local buf = vim.api.nvim_create_buf(false, true)
        local contents = vim.lsp.util.convert_input_to_markdown_lines(result.contents)

        vim.api.nvim_buf_set_lines(buf, 0, -1, false, contents)
        vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
        vim.api.nvim_buf_set_option(buf, "modifiable", false)
        vim.api.nvim_buf_set_option(buf, "buftype", "nofile")

        vim.cmd("vsplit")
        vim.api.nvim_win_set_buf(0, buf)

        vim.api.nvim_win_set_option(0, "wrap", true)
        vim.api.nvim_win_set_option(0, "linebreak", true)

        vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, silent = true })
      end)
    end, { desc = "LSP: Open hover in new buffer" })

    map("n", "<C-k>", vim.lsp.buf.signature_help, { desc = "LSP: Signature help" })
    map("n", "gD", vim.lsp.buf.declaration, { desc = "LSP: Go to declaration" })
    map("n", "gi", vim.lsp.buf.implementation, { desc = "LSP: Go to implementation" })
    map("n", "gt", vim.lsp.buf.type_definition, { desc = "LSP: Go to type definition" })
    map("n", "gr", vim.lsp.buf.references, { desc = "LSP: Show references" })

    map("n", "<space>rn", vim.lsp.buf.rename, { desc = "LSP: Rename symbol" })
    map({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, { desc = "LSP: Code actions" })

    map("n", "<space>wa", vim.lsp.buf.add_workspace_folder, { desc = "LSP: Add workspace folder" })
    map("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, { desc = "LSP: Remove workspace folder" })
    map("n", "<space>wl", function()
      vim.print(vim.lsp.buf.list_workspace_folders())
    end, { desc = "LSP: List workspace folders" })

    map("n", "<space>ds", vim.lsp.buf.document_symbol, { desc = "LSP: Document symbols" })
    map("n", "<space>ws", vim.lsp.buf.workspace_symbol, { desc = "LSP: Workspace symbols" })

    if
      client.server_capabilities.documentFormattingProvider
      and client.name ~= "lua_ls"
      and client.name ~= "pyright"
      and client.name ~= "ruff"
      and client.name ~= "rust_analyzer"
    then
      map({ "n", "x" }, "<space>f", function()
        vim.lsp.buf.format {
          async = false,
          filter = function(c)
            return c.id == client.id
          end,
        }
      end, { desc = "LSP: Format code" })
    end

    if client.name == "ruff" then
      client.server_capabilities.hoverProvider = false
    end

    if client.server_capabilities.documentHighlightProvider then
      local gid = vim.api.nvim_create_augroup("lsp_document_highlight_" .. bufnr, { clear = true })
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

    -- if client.server_capabilities.inlayHintProvider then
    --     vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    -- end

    if client.server_capabilities.completionProvider then
      vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = false })
    end
  end,
  nested = true,
  desc = "Configure buffer keymap and behavior based on LSP",
})

vim.diagnostic.config {
  underline = false,
  virtual_text = false,
  virtual_lines = false,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "🆇",
      [vim.diagnostic.severity.WARN] = "⚠️",
      [vim.diagnostic.severity.INFO] = "ℹ️",
      [vim.diagnostic.severity.HINT] = "",
    },
  },
  severity_sort = true,
  float = {
    source = true,
    header = "Diagnostics:",
    prefix = " ",
    border = "single",
    focusable = false,
  },
}

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
      vim.diagnostic.open_float()
    end

    vim.b.diagnostics_pos = cursor_pos
  end,
})

vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
vim.keymap.set("n", "<space>dl", vim.diagnostic.setloclist, { desc = "Diagnostics to location list" })
vim.keymap.set("n", "<space>dq", vim.diagnostic.setqflist, { desc = "Diagnostics to quickfix" })
