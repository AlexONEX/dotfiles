if not vim.fn.executable("jdtls-wrapper") then
  return
end

local root_dir = require("jdtls.setup").find_root { ".git", "gradlew", "mvnw" } or vim.fn.getcwd()
local workspace_dir = vim.fn.expand("~/.local/share/jdtls/workspace/") .. vim.fn.fnamemodify(root_dir, ":t")
local lombok_jar = vim.fn.expand("~/.m2/repository/org/projectlombok/lombok/1.18.30/lombok-1.18.30.jar")

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.foldingRange = {
  dynamicRegistration = false,
  lineFoldingOnly = true,
}

require("jdtls").start_or_attach {
  cmd = {
    "jdtls-wrapper",
    "--jvm-arg=-javaagent:" .. lombok_jar,
    "--jvm-arg=-Xmx4g",
    "-data",
    workspace_dir,
  },
  capabilities = capabilities,
  settings = {
    java = {
      format = { enabled = true },
      completion = {
        importOrder = { "java", "javax", "jakarta", "org", "com" },
        favoriteStaticMembers = {
          "org.junit.jupiter.api.Assertions.*",
          "org.mockito.Mockito.*",
        },
      },
      inlayHints = {
        parameterNames = { enabled = "all" },
      },
      codeGeneration = {
        toString = { template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}" },
        useBlocks = true,
      },
      contentProvider = { preferred = "fernflower" },
      references = { includeDecompiledSources = true },
    },
  },
}
