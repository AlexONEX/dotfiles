if not vim.fn.executable("jdtls") then
  return
end

local root_dir = require("jdtls.setup").find_root { ".git", "gradlew", "mvnw" } or vim.fn.getcwd()
local workspace_dir = vim.fn.expand("~/.local/share/jdtls/workspace/") .. vim.fn.fnamemodify(root_dir, ":t")
local lombok_jar = vim.fn.expand("~/.m2/repository/org/projectlombok/lombok/1.18.30/lombok-1.18.30.jar")

local cmd = { "jdtls" }

-- On macOS ARM, jdtls.py picks config_mac (x86_64 launcher), override to config_mac_arm
if vim.g.is_mac and jit.arch == "arm64" then
  local jdtls_home = vim.fn.trim(vim.fn.system("brew --prefix jdtls"))
  table.insert(cmd, "--jvm-arg=-Dosgi.sharedConfiguration.area=" .. jdtls_home .. "/libexec/config_mac_arm")
end

vim.list_extend(cmd, {
  "--jvm-arg=-javaagent:" .. lombok_jar,
  "--jvm-arg=-Xmx2g",
  "--jvm-arg=-XX:+UseG1GC",
  "--jvm-arg=-XX:+ParallelRefProcEnabled",
  "--jvm-arg=-XX:-OmitStackTraceInFastThrow",
  "-data",
  workspace_dir,
})

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.foldingRange = {
  dynamicRegistration = false,
  lineFoldingOnly = true,
}

require("jdtls").start_or_attach {
  cmd = cmd,
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
