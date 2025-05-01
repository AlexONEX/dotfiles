vim.loader.enable()

local utils = require("utils")
local expected_version = "0.11.1"
utils.is_compatible_version(expected_version)

local config_dir = vim.fn.stdpath("config")
---@cast config_dir string

-- some global settings
require("globals")
-- setting options in nvim
vim.cmd("source " .. vim.fs.joinpath(config_dir, "viml_conf/options.vim"))
-- various autocommands
require("custom-autocmd")
-- all the user-defined mappings
require("mappings")
-- Nvim quality of life improvements
require("improvements")
-- all the plugins installed and their configurations
vim.cmd("source " .. vim.fs.joinpath(config_dir, "viml_conf/plugins.vim"))

-- diagnostic related config
require("diagnostic-conf")

-- colorscheme settings
require("colorschemes")
local color_scheme = require("colorschemes")

-- Load colorscheme
color_scheme.load_colorscheme("nord")
