local utils = require("utils")
local M = {}

local use_theme = vim.cmd.colorscheme

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
    use_theme("edge")
  end,
  sonokai = function()
    vim.g.sonokai_enable_italic = 1
    vim.g.sonokai_better_performance = 1
    use_theme("sonokai")
  end,
  gruvbox_material = function()
    -- foreground option can be material, mix, or original
    vim.g.gruvbox_material_foreground = "original"
    --background option can be hard, medium, soft
    vim.g.gruvbox_material_background = "hard"
    vim.g.gruvbox_material_enable_italic = 1
    vim.g.gruvbox_material_better_performance = 1
    use_theme("gruvbox-material")
  end,
  everforest = function()
    vim.g.everforest_background = "hard"
    vim.g.everforest_enable_italic = 1
    vim.g.everforest_better_performance = 1
    use_theme("everforest")
  end,
  nightfox = function()
    vim.cmd([[colorscheme nordfox]])
  end,
  catppuccin = function()
    -- available option: latte, frappe, macchiato, mocha
    vim.g.catppuccin_flavour = "frappe"
    require("catppuccin").setup()
    use_theme("catppuccin")
  end,
  onedarkpro = function()
    -- set colorscheme after options
    -- onedark_vivid does not enough contrast
    use_theme("onedark_vivid")
  end,
  material = function()
    vim.g.material_style = "darker"
    use_theme("material")
  end,
  arctic = function()
    use_theme("arcticicestudio")
  end,
  kanagawa = function()
    use_theme("kanagawa")
  end,
  nord = function()
    use_theme("nord")
  end,
  modus = function()
    use_theme("modus-vivendi")
  end,
  jellybeans = function()
    use_theme("jellybeans")
  end,
  github = function()
    use_theme("github_dark_default")
  end,
  github_light = function()
    use_theme("github_light_default")
  end,
  e_ink = function()
    require("e-ink").setup()
    use_theme("e-ink")
  end,
  ashen = function()
    use_theme("ashen")
  end,
  melange = function()
    use_theme("melange")
  end,
  makurai = function()
    use_theme("makurai")
  end,
  vague = function()
    use_theme("vague")
  end,
  kanso = function()
    use_theme("kanso")
  end,
}

M.load_colorscheme = function(colorscheme)
  if not vim.tbl_contains(vim.tbl_keys(M.colorscheme_conf), colorscheme) then
    local msg = "Invalid colorscheme: " .. colorscheme
    vim.notify(msg, vim.log.levels.ERROR, { title = "nvim-config" })
    return
  end

  M.colorscheme_conf[colorscheme]()

  if vim.g.logging_level == "debug" then
    local msg = "Colorscheme: " .. colorscheme
    vim.notify(msg, vim.log.levels.DEBUG, { title = "nvim-config" })
  end
end

M.get_alacritty_mode = function()
  local alacritty_config = vim.fs.joinpath(vim.env.HOME, ".config", "alacritty", "alacritty.toml")
  local pattern = "dark"
  local handle = io.popen("grep -i " .. pattern .. " " .. alacritty_config)
  local result = handle:read("*a")
  handle:close()
  if result == "" then
    return "light"
  else
    return "dark"
  end
end
return M
