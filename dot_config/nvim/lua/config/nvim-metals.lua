-- nvim-metals.lua
local M = {}

M.setup = function()
  -- Ensure the required dependencies are installed
  local status_ok, metals = pcall(require, "metals")
  if not status_ok then
    print("Error loading nvim-metals:", metals)
    return
  end

  metals.initialize_or_attach({
    -- Metals server command
    cmd = {"metals", "--stdio"},

    -- Example settings
    settings = {
      showImplicitArguments = true,
      showInferredType = true,
      -- ... add more settings as needed
    },

    -- Example key mappings
    on_attach = function(client, bufnr)
      local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
      local opts = {noremap = true, silent = true}

      -- Mappings for metals, adjust as needed
      buf_set_keymap('n', '<leader>td', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
      buf_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
      buf_set_keymap('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
      -- ... add more mappings as needed
    end,

    -- Example capabilities
    capabilities = vim.lsp.protocol.make_client_capabilities(),
  })
end

return M
