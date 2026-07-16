local plugin_dir = vim.fn.stdpath("data") .. "/lazy"
local lazypath = plugin_dir .. "/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

local plugin_specs = {
  -- auto-completion engine
  {
    "saghen/blink.cmp",
    version = "*",
    event = "InsertEnter",
    config = function()
      require("config.blink-cmp")
    end,
  },

  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("config.nvim-lint")
    end,
  },

  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
    },
  },

  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("config.lsp")
    end,
  },

  { "mfussenegger/nvim-jdtls", ft = "java" },

  {
    "dnlhc/glance.nvim",
    config = function()
      require("config.glance")
    end,
    event = "VeryLazy",
  },
  {
    "nvim-treesitter/nvim-treesitter",
    enabled = function()
      return vim.g.is_mac or vim.g.is_linux
    end,
    event = { "BufReadPost", "BufNewFile" },
    branch = "main",
    build = ":TSUpdate",
    dependencies = {
      { "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
    },
    config = function()
      require("config.treesitter")
    end,
  },

  { "machakann/vim-swap", event = "VeryLazy" },

  -- Super fast buffer jump
  {
    "smoka7/hop.nvim",
    keys = { "f" },
    config = function()
      require("config.nvim_hop")
    end,
  },

  {
    "ibhagwan/fzf-lua",
    event = "VeryLazy",
    config = function()
      require("config.fzf-lua")
    end,
  },

  {
    "MeanderingProgrammer/markdown.nvim",
    main = "render-markdown",
    opts = {},
    ft = { "markdown" },
  },

  { "shaunsingh/nord.nvim", lazy = true },
  { "projekt0n/github-nvim-theme", name = "github-theme", lazy = true },
  { "e-ink-colorscheme/e-ink.nvim", lazy = true },

  -- plugins to provide nerdfont icons
  {
    "echasnovski/mini.icons",
    version = false,
    config = function()
      -- this is the compatibility fix for plugins that only support nvim-web-devicons
      require("mini.icons").mock_nvim_web_devicons()
      require("mini.icons").tweak_lsp_kind()
    end,
    lazy = false,
  },

  {
    "nvim-lualine/lualine.nvim",
    event = "BufRead",
    config = function()
      require("config.lualine")
    end,
  },

  {
    "akinsho/bufferline.nvim",
    event = { "BufEnter" },
    config = function()
      require("config.bufferline")
    end,
  },

  -- fancy start screen
  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    config = function()
      require("config.dashboard-nvim")
    end,
  },

  {
    "nvim-mini/mini.indentscope",
    version = false,
    event = "BufReadPost",
    config = function()
      local mini_indent = require("mini.indentscope")
      mini_indent.setup {
        draw = {
          animation = mini_indent.gen_animation.none(),
        },
        symbol = "▏",
      }
    end,
  },

  -- mini.ai: extended textobjects (a/i for argument, function call, etc.)
  -- Disables treesitter af/if/ac/ic since mini.ai covers them better.
  {
    "nvim-mini/mini.ai",
    version = false,
    event = "VeryLazy",
    config = function()
      require("mini.ai").setup {
        n_lines = 50,
      }
    end,
  },

  -- mini.splitjoin: split/join arguments with gS
  {
    "nvim-mini/mini.splitjoin",
    version = false,
    event = "VeryLazy",
    config = function()
      require("mini.splitjoin").setup()
    end,
  },

  -- mini.bracketed: [] bracket navigation for diagnostics, buffers, etc.
  -- Disabled targets that clash:
  --   comment (c) → clashes with treesitter ]c/[c (class jump)
  --   file (f)    → clashes with treesitter ]f/[f (function jump)
  --   oldfile (o) → clashes with opencode ]o/[o
  {
    "nvim-mini/mini.bracketed",
    version = false,
    event = "VeryLazy",
    config = function()
      require("mini.bracketed").setup {
        buffer = { suffix = "b", options = {} },
        comment = { suffix = "", options = {} }, -- disabled: clashes with treesitter ]c/[c
        conflict = { suffix = "x", options = {} },
        diagnostic = { suffix = "d", options = {} },
        file = { suffix = "", options = {} }, -- disabled: clashes with treesitter ]f/[f
        indent = { suffix = "i", options = {} },
        jump = { suffix = "j", options = {} },
        location = { suffix = "l", options = {} },
        oldfile = { suffix = "", options = {} }, -- disabled: clashes with opencode ]o/[o
        quickfix = { suffix = "q", options = {} },
        treesitter = { suffix = "t", options = {} },
        undo = { suffix = "u", options = {} },
        window = { suffix = "w", options = {} },
        yank = { suffix = "y", options = {} },
      }
    end,
  },
  {
    "luukvbaal/statuscol.nvim",
    event = "BufReadPost",
    opts = {},
    config = function()
      require("config.nvim-statuscol")
    end,
  },
  {
    "kevinhwang91/nvim-ufo",
    dependencies = "kevinhwang91/promise-async",
    event = "VeryLazy",
    opts = {},
    init = function()
      vim.o.foldcolumn = "1" -- '0' is not bad
      vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
    end,
    config = function()
      require("config.nvim_ufo")
    end,
  },
  { "nvim-lua/plenary.nvim", lazy = true },

  -- Snippet engine and snippet collection
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    event = "InsertEnter",
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },

  -- Automatic insertion and deletion of a pair of characters
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "InsertEnter",
    opts = {},
  },

  -- Multiple cursor plugin like Sublime Text?
  { "mg979/vim-visual-multi", event = "VeryLazy" },

  -- Handy unix command inside Vim (Rename, Move etc.)
  { "tpope/vim-eunuch", cmd = { "Rename", "Delete" } },

  -- Repeat vim motions
  { "tpope/vim-repeat", event = "VeryLazy" },

  {
    "lyokha/vim-xkbswitch",
    enabled = function()
      return vim.g.is_mac and vim.fn.executable("xkbswitch") > 0
    end,
    event = { "InsertEnter" },
  },

  -- Git command inside vim
  {
    "tpope/vim-fugitive",
    event = "User InGitRepo",
    config = function()
      require("config.fugitive")
    end,
  },

  -- Better git log display
  { "rbong/vim-flog", cmd = { "Flog" } },
  {
    "akinsho/git-conflict.nvim",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("config.git-conflict")
    end,
  },
  {
    "ruifm/gitlinker.nvim",
    event = "User InGitRepo",
    config = function()
      require("config.git-linker")
    end,
  },

  -- Show git change (change, delete, add) signs in vim sign column
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("config.gitsigns")
    end,
    event = "BufRead",
    version = "*",
  },

  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen" },
  },

  {
    "kevinhwang91/nvim-bqf",
    ft = "qf",
    opts = {
      auto_resize_height = false,
      preview = {
        auto_preview = false,
      },
    },
  },

  -- Markdown previewing (only for Mac and Windows)
  {
    "iamcco/markdown-preview.nvim",
    enabled = function()
      return vim.g.is_win or vim.g.is_mac
    end,
    build = "cd app && npm install && git restore .",
    ft = { "markdown" },
  },

  { "chrisbra/unicode.vim", keys = { "ga" }, cmd = { "UnicodeSearch" } },

  -- Additional powerful text object for vim, this plugin should be studied
  -- carefully to use its full power
  { "wellle/targets.vim", event = "VeryLazy" },

  -- Only use these plugin on Windows and Mac and when LaTeX is installed
  {
    "lervag/vimtex",
    ft = { "tex" },
    enabled = function()
      return vim.fn.executable("latex") > 0
    end,
    config = function()
      vim.g.vimtex_view_method = "zathura"
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_compiler_automatic_compilation = 1
      vim.g.vimtex_quickfix_mode = 0
      vim.g.vimtex_quickfix_enabled = 1
      -- vimtex syntax is better than treesitter for LaTeX
      --vim.g.tex_conceal = "abdmg"
      vim.g.vimtex_filetypes = { "tex" }
      vim.g.vimtex_mappings_enabled = 0 -- disable all defaults, we use <space>l prefix
      vim.opt.conceallevel = 2
    end,
  },

  {
    "epwalsh/obsidian.nvim",
    event = "VeryLazy",
    ft = "markdown",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("config.obsidian-nvim")
    end,
  },

  -- Since tmux is only available on Linux and Mac, we only enable these plugins
  -- for Linux and Mac
  -- .tmux.conf syntax highlighting and setting check
  {
    "tmux-plugins/vim-tmux",
    enabled = function()
      return vim.fn.executable("tmux") > 0
    end,
    ft = { "tmux" },
  },

  -- Asynchronous command execution
  { "skywind3000/asyncrun.vim", lazy = true, cmd = { "AsyncRun" } },
  { "hashivim/vim-terraform", ft = { "terraform", "terraform-vars" } },

  -- Session management plugin

  -- showing keybindings
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      icons = {
        mappings = false,
      },
    },
  },

  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      input = {
        enabled = true,
        win = {
          relative = "cursor",
          backdrop = true,
        },
      },
      explorer = { enabled = true },
      notifier = { enabled = true },
    },
  },

  {
    "zbirenbaum/copilot.lua",
    event = "VeryLazy",
    config = function()
      require("config.copilot")
    end,
  },

  {
    "nickjvandyke/opencode.nvim",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("config.opencode")
    end,
  },

  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
  {
    "smjonas/live-command.nvim",
    -- live-command supports semantic versioning via Git tags
    -- tag = "2.*",
    event = "VeryLazy",
    config = function()
      require("config.live-command")
    end,
  },
  {
    -- show hint for code actions, the user can also implement code actions themselves,
    -- see discussion here: https://github.com/neovim/neovim/issues/14869
    "kosayoda/nvim-lightbulb",
    config = function()
      require("config.lightbulb")
    end,
    event = "LspAttach",
  },

  {
    "Bekaboo/dropbar.nvim",
    event = "VeryLazy",
  },
  {
    "catgoose/nvim-colorizer.lua",
    event = "BufReadPre",
  },
}

---@diagnostic disable-next-line: missing-fields
require("lazy").setup {
  spec = plugin_specs,
  ui = {
    border = "rounded",
    title = "Plugin Manager",
    title_pos = "center",
  },
  rocks = {
    enabled = false,
    hererocks = false,
  },
}
