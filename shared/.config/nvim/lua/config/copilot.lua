require("copilot").setup {
  panel = {
    enabled = true,
    auto_refresh = false,
    keymap = {
      jump_prev = "[[",
      jump_next = "]]",
      accept = "<CR>",
      refresh = "gr",
      --open = "<M-CR>"
    },
    layout = {
      position = "bottom",
      ratio = 0.4,
    },
  },
  suggestion = {
    enabled = true,
    auto_trigger = true,
    debounce = 75,
    keymap = {
      accept = "<M-,>",
      accept_word = "<M-w>",
      accept_line = "<M-l>",
      next = "<M-]>",
      prev = "<M-[>",
      dismiss = "<C-]>",
    },
  },
  filetypes = {
    yaml = false,
    markdown = false,
    help = false,
    gitcommit = false,
    gitrebase = false,
    hgcommit = false,
    svn = false,
    cvs = false,
    ["."] = false,
  },
  copilot_node_command = "node",
  server_opts_overrides = {},
}

vim.api.nvim_create_user_command("KeybindsCopilot", function()
  local lines = {
    "Copilot keybindings (suggestion mode):",
    "",
    "  <M-,>    Accept all suggestion",
    "  <M-l>    Accept line",
    "  <M-w>    Accept word",
    "  <M-]>    Next suggestion",
    "  <M-[>    Prev suggestion",
    "  <C-]>    Dismiss suggestion",
  }
  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "Copilot Keybinds" })
end, { desc = "Show copilot keybindings" })
