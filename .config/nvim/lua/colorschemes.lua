--- This module will load a random colorscheme on nvim startup process.
local utils = require("utils")
local M = {}

-- Colorscheme to its directory name mapping, because colorscheme repo name is not necessarily
-- the same as the colorscheme name itself.
M.colorscheme_conf = {
  onedark = function()
    -- Lua
    require("onedark").setup {
      style = "darker",
    }
    require("onedark").load()
  end,
  edge = function()
    vim.g.edge_style = "default"
    vim.g.edge_enable_italic = 1
    vim.g.edge_better_performance = 1
    vim.cmd([[colorscheme edge]])
  end,
  sonokai = function()
    vim.g.sonokai_enable_italic = 1
    vim.g.sonokai_better_performance = 1
    vim.cmd([[colorscheme sonokai]])
  end,
  gruvbox_material = function()
    -- foreground option can be material, mix, or original
    vim.g.gruvbox_material_foreground = "original"
    --background option can be hard, medium, soft
    vim.g.gruvbox_material_background = "hard"
    vim.g.gruvbox_material_enable_italic = 1
    vim.g.gruvbox_material_better_performance = 1
    vim.cmd([[colorscheme gruvbox-material]])
  end,
  everforest = function()
    vim.g.everforest_background = "hard"
    vim.g.everforest_enable_italic = 1
    vim.g.everforest_better_performance = 1
    vim.cmd([[colorscheme everforest]])
  end,
  nightfox = function()
    vim.cmd([[colorscheme nordfox]])
  end,
  catppuccin = function()
    -- available option: latte, frappe, macchiato, mocha
    vim.g.catppuccin_flavour = "frappe"
    require("catppuccin").setup()
    vim.cmd([[colorscheme catppuccin]])
  end,
  onedarkpro = function()
    -- set colorscheme after options
    -- onedark_vivid does not enough contrast
    vim.cmd("colorscheme onedark_dark")
  end,
  material = function()
    vim.g.material_style = "darker"
    vim.cmd("colorscheme material")
  end,
  arctic = function()
    vim.cmd("colorscheme arctic")
  end,
  kanagawa = function()
    vim.cmd("colorscheme kanagawa-wave")
  end,
  nord = function()
    vim.cmd("colorscheme nord")
  end,
  modus = function()
    vim.cmd([[colorscheme modus]])
  end,
  jellybeans = function()
    vim.cmd([[colorscheme jellybeans]])
  end,
  github = function()
    vim.cmd([[colorscheme github_dark_default]])
  end,
  e_ink = function()
    require("e-ink").setup()
    vim.cmd.colorscheme("e-ink")
  end,
  ashen = function()
    vim.cmd([[colorscheme ashen]])
  end,
  melange = function()
    vim.cmd([[colorscheme melange]])
  end,
  makurai = function()
    vim.cmd.colorscheme("makurai_warrior")
  end,
  vague = function()
    vim.cmd([[colorscheme vague]])
  end,
  kanso = function()
    vim.cmd([[colorscheme kanso]])
  end,
}

--- Use a random colorscheme from the pre-defined list of colorschemes.
M.rand_colorscheme = function()
  local colorscheme = utils.rand_element(vim.tbl_keys(M.colorscheme_conf))

  if not vim.tbl_contains(vim.tbl_keys(M.colorscheme_conf), colorscheme) then
    local msg = "Invalid colorscheme: " .. colorscheme
    vim.notify(msg, vim.log.levels.ERROR, { title = "nvim-config" })
    return
  end

  -- Load the colorscheme and its settings
  M.colorscheme_conf[colorscheme]()
end

M.load_colorscheme = function(colorscheme)
  if not vim.tbl_contains(vim.tbl_keys(M.colorscheme_conf), colorscheme) then
    local msg = "Invalid colorscheme: " .. colorscheme
    vim.notify(msg, vim.log.levels.ERROR, { title = "nvim-config" })
    return
  end

  -- Load the colorscheme and its settings
  M.colorscheme_conf[colorscheme]()

  if vim.g.logging_level == "debug" then
    local msg = "Colorscheme: " .. colorscheme
    vim.notify(msg, vim.log.levels.DEBUG, { title = "nvim-config" })
  end
end

return M
