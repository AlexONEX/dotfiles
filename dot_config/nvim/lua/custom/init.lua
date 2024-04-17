local autocmd = vim.api.nvim_create_autocmd
-- Auto resize panes when resizing nvim window
autocmd("VimResized", {
  pattern = "*",
  command = "tabdo wincmd =",
})

autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    require("conform").format { async = true }
  end,
})

autocmd({ "BufWritePost" }, {
  callback = function()
    require("lint").try_lint()
  end,
})

-- Conceal level 2 for latex and bibtex files
autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.tex", "*.bib" },
  command = "setlocal conceallevel=2",
})

local function load_configs(path)
  local scan = vim.fs.dir(path)
  for filename in scan do
    if filename:match "%.lua$" then
      local filepath = path .. "." .. filename:gsub("%.lua$", "")
      require(filepath)
    end
  end
end

load_configs "after.ftplugin"

-- Global options
local fn = vim.fn
local api = vim.api

local utils = require "custom.utils"

-- Inspect something
function _G.inspect(item)
  vim.print(item)
end

--clipboard unnamedplus
vim.o.clipboard = "unnamedplus"

------------------------------------------------------------------------
--                          custom variables                          --
------------------------------------------------------------------------
vim.g.is_win = (utils.has "win32" or utils.has "win64") and true or false
vim.g.is_linux = (utils.has "unix" and (not utils.has "macunix")) and true or false
vim.g.is_mac = utils.has "macunix" and true or false
vim.g.logging_level = "info"

------------------------------------------------------------------------
--                         builtin variables                          --
------------------------------------------------------------------------
vim.g.loaded_perl_provider = 0 -- Disable perl provider
vim.g.loaded_ruby_provider = 0 -- Disable ruby provider
vim.g.loaded_node_provider = 0 -- Disable node provider

local enable_providers = {
  "python3_provider",
}

for _, plugin in pairs(enable_providers) do
  vim.g["loaded_" .. plugin] = nil
  vim.cmd("runtime " .. plugin)
end

vim.g.did_install_default_menus = 1 -- do not load menu

-- Custom mapping <leader> (see `:h mapleader` for more info)
vim.g.mapleader = " "
vim.o.guifont = "CaskaydiaCove Nerd Font:h9"
vim.g.neovide_scroll_animation_length = 0.0
vim.g.neovide_cursor_animation_length = 0.0
vim.o.autowriteall = true
