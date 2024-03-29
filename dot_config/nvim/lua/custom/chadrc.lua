---@type ChadrcConfig
local M = {}

-- Path to overriding theme and highlights files
local highlights = require "custom.highlights"

M.ui = {

  hl_override = highlights.override,
  hl_add = highlights.add,

  theme_toggle = { "nord", "onenord_light" },
  theme = "nord", -- default theme
  transparency = false,
  lsp_semantic_tokens = false, -- needs nvim v0.9, just adds highlight groups for lsp semantic tokens

  -- https://github.com/NvChad/base46/tree/v2.0/lua/base46/extended_integrations
  extended_integrations = {}, -- these aren't compiled by default, ex: "alpha", "notify"

  -- cmp themeing
  cmp = {
    icons = true,
    lspkind_text = true,
    style = "default", -- default/flat_light/flat_dark/atom/atom_colored
    border_color = "grey_fg", -- only applicable for "default" style, use color names from base30 variables
    selected_item_bg = "colored", -- colored / simple
  },

  telescope = { style = "borderless" }, -- borderless / bordered

  statusline = {
    theme = "vscode_colored", -- default/vscode/vscode_colored/minimal
    -- default/round/block/arrow separators work only for default statusline theme
    -- round and block will work for minimal theme only
    separator_style = "default",
    overriden_modules = nil,
  },

  -- lazyload it when there are 1+ buffers
  tabufline = {
    show_numbers = true,
    enabled = true,
    lazyload = true,
    overriden_modules = nil,
  },

  nvdash = {
    load_on_startup = true,
    header = {
      "                                     ",
      "                                     ",
      "                                     ",
      " ███╗   ██╗ ██╗   ██╗ ██╗ ███╗   ███╗",
      " ████╗  ██║ ██║   ██║ ██║ ████╗ ████║",
      " ██╔██╗ ██║ ██║   ██║ ██║ ██╔████╔██║",
      " ██║╚██╗██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║",
      " ██║ ╚████║  ╚████╔╝  ██║ ██║ ╚═╝ ██║",
      " ╚═╝  ╚═══╝   ╚═══╝   ╚═╝ ╚═╝     ╚═╝",
      "                                     ",
      "                                     ",
      "                                     ",
      "                                     ",
    },
  },

  buttons = {
    { "  Find File", "Spc f f", "Telescope find_files" },
    { "󰈚  Recent Files", "Spc f o", "Telescope oldfiles" },
    { "󰈭  Find Word", "Spc f w", "Telescope live_grep" },
    { "  Bookmarks", "Spc m a", "Telescope marks" },
    { "  Themes", "Spc t h", "Telescope themes" },
    { "  Mappings", "Spc c h", "NvCheatsheet" },
  },

  cheatsheet = { theme = "grid" }, -- simple/grid

  lsp = {
    -- show function signatures i.e args as you type
    signature = {
      disabled = false,
      silent = true, -- silences 'no signature help available' message from appearing
    },
  },
}

M.plugins = "custom.plugins"

-- check core.mappings for table structure
M.mappings = require "custom.mappings"

return M
