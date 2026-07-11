vim.loader.enable()

local utils = require("utils")
local expected_version = "0.12.4"
utils.is_compatible_version(expected_version)

-- some global settings
require("globals")
-- setting options in nvim
require("config.options")
-- various autocommands
require("custom-autocmd")
-- all the user-defined mappings
require("mappings")
-- Fix common typos
vim.cmd("iabbrev reqire require")
vim.cmd("iabbrev serveral several")

-- plugin specs & lazy.nvim bootstrap (was viml_conf/plugins.vim)
require("plugin_specs")
-- user commands (was plugin/command.lua)
require("commands")
-- plugin settings
require("config.plugin-settings")

-- GUI settings (was ginit.vim)
require("gui")

-- filetype detection (was ftdetect/*.vim)
require("ftdetect")

-- diagnostic related config
require("diagnostic-conf")

-- colorscheme settings
require("colorschemes").load_colorscheme("nord")
