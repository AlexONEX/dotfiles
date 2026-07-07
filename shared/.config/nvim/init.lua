vim.loader.enable()

local utils = require("utils")
local expected_version = "0.12.3"
utils.is_compatible_version(expected_version)

-- some global settings
require("globals")
-- setting options in nvim
require("config.options")
-- various autocommands
require("custom-autocmd")
-- all the user-defined mappings
require("mappings")
-- Nvim quality of life improvements
require("improvements")
-- Fix common typos
vim.cmd("iabbrev reqire require")
vim.cmd("iabbrev serveral several")

-- plugin specs & lazy.nvim bootstrap (was viml_conf/plugins.vim)
require("plugin_specs")
-- plugin settings
require("config.plugin-settings")

-- GUI settings (was ginit.vim)
require("gui")

-- filetype detection (was ftdetect/*.vim)
require("ftdetect")

-- diagnostic related config
require("diagnostic-conf")

-- colorscheme settings
local color_scheme = require("colorschemes")
-- Detecta el tema del sistema desde Alacritty (si estamos fuera de tmux)
local in_tmux = vim.env.TMUX ~= nil
if not in_tmux and color_scheme.get_alacritty_mode() == "light" then
  color_scheme.load_colorscheme("github_light")
else
  color_scheme.load_colorscheme("nord")
end
