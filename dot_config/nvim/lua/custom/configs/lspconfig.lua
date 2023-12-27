local lspconfig = require "lspconfig"
local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

local lsp_servers = {
  "bashls", -- LSP para Bash
  "clangd", -- LSP para C y C++
  "cmake", -- LSP para CMake
  "cssls", -- LSP para CSS
  "dockerls", -- LSP para Dockerfiles
  "gopls", -- LSP para Go
  "graphql", -- LSP para GraphQL
  "html", -- LSP para HTML
  "jdtls", -- LSP para Java (Eclipse JDT)
  "jsonls", -- LSP para JSON
  "kotlin_language_server", -- LSP para Kotlin
  "omnisharp", -- LSP para C# (.NET)
  "phpactor", -- LSP para PHP
  "prismals", -- LSP para Prisma
  "pyright", -- LSP para Python
  "rust_analyzer", -- LSP para Rust
  "svelte", -- LSP para Svelte
  "terraformls", -- LSP para Terraform
  "texlab", -- LSP para LaTeX
  "tsserver", -- LSP para TypeScript y JavaScript
  "vimls", -- LSP para VimScript
  "vuels", -- LSP para Vue.js
  "yamlls", -- LSP para YAML
  "zls", -- LSP para Zig
}

-- Configuración de LSP para los servidores
for _, lsp in ipairs(lsp_servers) do
  lspconfig[lsp].setup {
    on_attach = function(client, bufnr)
      on_attach(client, bufnr) -- Usa la función on_attach común para LSP

      -- Desactiva las opciones de formateo y formato de rango
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false
    end,
    capabilities = capabilities,
  }
end
