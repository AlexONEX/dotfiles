local M = {}

local themes = {
  nord = "nord",
  github = "github_dark_default",
  github_light = "github_light_default",
  e_ink = nil,
}

M.load_colorscheme = function(colorscheme)
  local theme = themes[colorscheme]
  if theme == nil and colorscheme ~= "e_ink" then
    vim.notify("Invalid colorscheme: " .. colorscheme, vim.log.levels.ERROR, { title = "nvim-config" })
    return
  end

  if colorscheme == "e_ink" then
    require("e-ink").setup()
    vim.cmd.colorscheme("e-ink")
  else
    vim.cmd.colorscheme(theme)
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
