local utils = require("utils")
local M = {}

local use_theme = vim.cmd.colorscheme

-- Colorscheme to its directory name mapping, because colorscheme repo name is not necessarily
-- the same as the colorscheme name itself.
M.colorscheme_conf = {
  nord = function()
    use_theme("nord")
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
  for _, line in ipairs(vim.fn.readfile(alacritty_config)) do
    if line:lower():find("dark") then
      return "dark"
    end
  end
  return "light"
end
return M
