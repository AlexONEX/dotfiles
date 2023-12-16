require("nvim-treesitter.configs").setup {
  ensure_installed = { "python", "cpp", "lua", "vim", "json", "toml", "norg" },
  ignore_install = {}, -- List of parsers to ignore installing
  highlight = {
    enable = true, -- false will disable the whole extension
    disable = { "help" }, -- list of language that will be disabled
  },
  load = {
    ["core.defaults"] = {},
    ["core.dirman"] = {
      config = {
        workspaces = {
          work = "~/notes/work",
          home = "~/notes/home",
        },
      },
    },
  },
}
