local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
local workspace_dir = vim.fn.expand("~/.local/share/jdtls/workspace/") .. project_name

return {
  cmd = {
    "jdtls",
    "--jvm-arg=-javaagent:" .. vim.fn.expand("~/.m2/repository/org/projectlombok/lombok/1.18.30/lombok-1.18.30.jar"),
    "-data",
    workspace_dir,
  },
  filetypes = { "java" },
  root_markers = { "pom.xml", "build.gradle", "build.gradle.kts", ".git" },
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
    },
  },
}
