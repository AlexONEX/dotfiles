if not vim.fn.executable("jdtls") then
  return
end

local root_dir = require("jdtls.setup").find_root { ".git", "gradlew", "mvnw" } or vim.fn.getcwd()
local workspace_dir = vim.fn.expand("~/.local/share/jdtls/workspace/") .. vim.fn.fnamemodify(root_dir, ":t")
-- Lombok lives in the Maven repo (Maven projects) or the Gradle cache (Gradle projects).
local lombok_patterns = {
  "~/.m2/repository/org/projectlombok/lombok/*/lombok-*.jar",
  "~/.gradle/caches/modules-2/files-2.1/org.projectlombok/lombok/*/*/lombok-*.jar",
}
local lombok_jar = ""
for _, pattern in ipairs(lombok_patterns) do
  for _, jar in ipairs(vim.fn.glob(vim.fn.expand(pattern), false, true)) do
    if not jar:match("%-sources%.jar$") and not jar:match("%-javadoc%.jar$") then
      lombok_jar = jar -- keep last = highest version
    end
  end
end

local cmd = { "jdtls", "--jvm-arg=-Djava.import.generatesMetadataFilesAtProjectRoot=false" }

-- On macOS ARM, jdtls.py picks config_mac (x86_64 launcher), override to config_mac_arm
if vim.g.is_mac and jit.arch == "arm64" then
  local jdtls_home = vim.fn.trim(vim.fn.system("brew --prefix jdtls"))
  table.insert(cmd, "--jvm-arg=-Dosgi.sharedConfiguration.area=" .. jdtls_home .. "/libexec/config_mac_arm")
end

if lombok_jar ~= "" then
  table.insert(cmd, "--jvm-arg=-javaagent:" .. lombok_jar)
end
vim.list_extend(cmd, {
  "--jvm-arg=-Xmx4g",
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

-- Gradle 8.5 (and buildship) only support JDK <= 21; a newer JAVA_HOME (22/26)
-- deadlocks the Gradle import. Pin jdtls + its child Gradle daemon to JDK 21.
local java21 = vim.fn.trim(vim.fn.system("/usr/libexec/java_home -v 21 2>/dev/null"))

require("jdtls").start_or_attach {
  cmd = cmd,
  cmd_env = java21 ~= "" and { JAVA_HOME = java21 } or nil,
  capabilities = capabilities,
  on_exit = function(code, signal, _)
    if code ~= 0 or signal ~= 0 then
      vim.fn.delete(workspace_dir, "rf")
      vim.schedule(function()
        vim.notify("jdtls exited dirty: workspace wiped, reopen the .java file", vim.log.levels.WARN)
      end)
    end
  end,
  settings = {
    java = {
      saveActions = { organizeImports = true },
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
