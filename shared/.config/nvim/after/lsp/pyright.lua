-- ponytail: find .venv relative to the buffer's project root
local function find_venv_python(bufnr)
  local root = vim.fs.root(bufnr, { "pyproject.toml", ".git" })
  if not root then
    return nil
  end
  local p = root .. "/.venv/bin/python"
  if vim.fn.executable(p) == 1 then
    return p
  end
  local venv = os.getenv("VIRTUAL_ENV")
  if venv and venv ~= "" then
    p = venv .. "/bin/python"
    if vim.fn.executable(p) == 1 then
      return p
    end
  end
end

-- set pythonPath per-buffer before LSP starts
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function(ev)
    local py = find_venv_python(ev.buf)
    if py then
      vim.lsp.config("pyright", {
        settings = { python = { pythonPath = py } },
      })
    end
  end,
})

return {
  cmd = { "delance-langserver", "--stdio" },
  root_markers = { "pyproject.toml", ".git" },
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
