local M = {}

local themes = {
  nord = "nord",
  github_dark = "github_dark_default",
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

return M
