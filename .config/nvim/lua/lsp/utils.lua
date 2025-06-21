local M = {}

M.get_default_capabilities = function()
  local capabilities = vim.lsp.protocol.make_client_capabilities()

  -- required by nvim-ufo
  capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
  }

  return capabilities
end

function M.find_root(markers)
  local file_path = vim.api.nvim_buf_get_name(0)
  if file_path == "" then
    return nil
  end

  local dir = vim.fn.fnamemodify(file_path, ":h")
  local root = vim.fs.find(markers, { path = dir, upward = true })[1]
  return root
end

return M
