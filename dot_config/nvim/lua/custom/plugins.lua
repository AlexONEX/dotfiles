local overrides = require "custom.configs.overrides"
local utils = require "custom.utils"

---@type NvPluginSpec[]
local plugins = {

  -- Override plugin definition options
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "stevearc/conform.nvim",
        config = function()
          require "custom.configs.conform"
        end,
      },

      {
        "mfussenegger/nvim-lint",
        config = function()
          require "custom.configs.nvim-lint"
        end,
      },
    },
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end, -- Override to setup mason-lspconfig
  },

  {
    "nvim-tree/nvim-tree.lua",
    opts = overrides.nvimtree,
  },

  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "VeryLazy",
    config = function()
      require "custom.configs.copilot"
    end,
  },

  {
    "nvim-lua/plenary.nvim",
  },
  -- Dashboard
  {
    "nvimdev/dashboard-nvim",
    config = function()
      require "custom.config.dashboard-nvim"
    end,
  },

  -- Highlight URLs inside vim
  { "itchyny/vim-highlighturl", event = "VeryLazy" },

  -- Automatic insertion and deletion of a pair of characters
  { "Raimondi/delimitMate", event = "InsertEnter" },

  -- Automatic closing of HTML tags
  {
    "windwp/nvim-ts-autotag",
    ft = { "html", "js", "jsx", "ts", "tsx", "svelte", "vue", "md" },
    config = function()
      require("nvim-ts-autotag").setup()
    end,
  },

  -- Only install these plugins if ctags are installed on the system
  -- show file tags in vim window
  {
    "liuchengxu/vista.vim",
    enabled = function()
      if utils.executable "ctags" then
        return true
      else
        return false
      end
    end,
    cmd = "Vista",
  },

  -- Comment plugin
  { "tpope/vim-commentary", event = "VeryLazy" },

  -- Show undo history visually
  { "simnalamburt/vim-mundo", cmd = { "MundoToggle", "MundoShow" } },

  -- better UI for some nvim actions
  { "stevearc/dressing.nvim" },

  { "nvim-zh/better-escape.vim", event = { "InsertEnter" } },

  -- Git Stuff
  -- Git command inside vim
  {
    "tpope/vim-fugitive",
    event = "User InGitRepo",
    config = function()
      require "custom.configs.fugitive"
    end,
  },

  -- Better git log display
  { "rbong/vim-flog", cmd = { "Flog" } },
  { "christoomey/vim-conflicted", cmd = { "Conflicted" } },
  {
    "ruifm/gitlinker.nvim",
    event = "User InGitRepo",
    config = function()
      require "custom.configs.git-linker"
    end,
  },

  -- Show git change (change, delete, add) signs in vim sign column
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require "custom.configs.gitsigns"
    end,
  },

  -- Better git commit experience
  { "rhysd/committia.vim", lazy = true },
  {
    "kevinhwang91/nvim-bqf",
    ft = "qf",
    config = function()
      require "custom.configs..bqf"
    end,
  },

  {
    "sindrets/diffview.nvim",
  },

  -- Modern matchit implementation
  { "andymass/vim-matchup", event = "BufRead" },
  { "tpope/vim-scriptease", cmd = { "Scriptnames", "Message", "Verbose" } },

  -- Asynchronous command execution
  { "skywind3000/asyncrun.vim", lazy = true, cmd = { "AsyncRun" } },
  { "cespare/vim-toml", ft = { "toml" }, branch = "main" },

  -- The missing auto-completion for cmdline!
  {
    "gelguy/wilder.nvim",
    build = ":UpdateRemotePlugins",
  },

  -- Super fast buffer jump
  {
    "smoka7/hop.nvim",
    event = "VeryLazy",
    config = function()
      require "custom.configs.hop"
    end,
  },

  -- IDEs
  -- Latex support
  {
    "lervag/vimtex",
    config = function()
      vim.g.vimtex_view_method = "zathura"
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_quickfix_enabled = 1
      vim.g.vimtex_syntax_enabled = 1
      vim.g.vimtex_quickfix_mode = 0
      vim.g.vimtex_filetypes = { "tex" }
    end,
  },

  -- IDE for Lisp
  {
    "vlime/vlime",
    enabled = function()
      if utils.executable "sbcl" then
        return true
      end
      return false
    end,
    config = function(plugin)
      vim.opt.rtp:append(plugin.dir .. "/vim")
    end,
    ft = { "lisp" },
  },
}

return plugins
