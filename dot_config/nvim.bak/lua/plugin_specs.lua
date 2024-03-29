local utils = require("utils")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- check if firenvim is active
local firenvim_not_active = function()
	return not vim.g.started_by_firenvim
end

local plugin_specs = {
	-- auto-completion engine
	{
		"hrsh7th/nvim-cmp",
		-- event = 'InsertEnter',
		event = "VeryLazy",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"onsails/lspkind-nvim",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-omni",
			"hrsh7th/cmp-emoji",
			"quangnguyen30192/cmp-nvim-ultisnips",
		},
		config = function()
			require("config.nvim-cmp")
		end,
	},

	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "VeryLazy",
		config = function()
			require("config.copilot")
		end,
	},

	{
		"neovim/nvim-lspconfig",
		event = { "BufRead", "BufNewFile" },
		config = function()
			require("config.lsp")
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter",
		event = "VeryLazy",
		build = ":TSUpdate",
		run = ":Neorg sync-parsers", -- This is the important bit!
		config = function()
			require("config.treesitter")
		end,
	},

	{ "machakann/vim-swap", event = "VeryLazy" },

	-- IDE for scala
	{
		"scalameta/nvim-metals",
		requires = {
			"nvim-lua/plenary.nvim",
		},
		config = function()
			require("config.nvim-metals")
		end,
		ft = { "scala", "sbt", "sc", "scastie", "worksheet.scala", "worksheet.sc" },
	},

	-- IDE for Lisp
	-- 'kovisoft/slimv'
	{
		"vlime/vlime",
		enabled = function()
			if utils.executable("sbcl") then
				return true
			end
			return false
		end,
		config = function(plugin)
			vim.opt.rtp:append(plugin.dir .. "/vim")
		end,
		ft = { "lisp" },
	},

	-- IDE for Java
	{
		"mfussenegger/nvim-jdtls",
		enabled = function()
			if utils.executable("jdtls") then
				return true
			end
			return false
		end,
		config = function()
			require("config.nvim-jdtls")
		end,
		ft = { "java" },
	},

	-- Super fast buffer jump
	{
		"smoka7/hop.nvim",
		event = "VeryLazy",
		config = function()
			require("config.nvim_hop")
		end,
	},

	-- Show match number and index for searching
	{
		"kevinhwang91/nvim-hlslens",
		branch = "main",
		keys = { "*", "#", "n", "N" },
		config = function()
			require("config.hlslens")
		end,
	},
	{
		"Yggdroot/LeaderF",
		cmd = "Leaderf",
		build = function()
			if not vim.g.is_win then
				vim.cmd(":LeaderfInstallCExtension")
			end
		end,
	},

	{
		"nvim-lua/plenary.nvim",
	},

	{
		"nvim-telescope/telescope.nvim",
		cmd = "Telescope",
		config = function()
			require("config.telescope")
		end,
		dependencies = {
			"nvim-telescope/telescope-symbols.nvim",
		},
	},

	-- A list of colorscheme plugin you may want to try. Find what suits you.
	{ "navarasu/onedark.nvim", lazy = true },
	{ "sainnhe/edge", lazy = true },
	{ "sainnhe/sonokai", lazy = true },
	{ "sainnhe/gruvbox-material", lazy = true },
	{ "gbprod/nord.nvim", lazy = true },
	{ "sainnhe/everforest", lazy = true },
	{ "EdenEast/nightfox.nvim", lazy = true },
	{ "rebelot/kanagawa.nvim", lazy = true },
	{ "catppuccin/nvim", name = "catppuccin", lazy = true },
	{ "rose-pine/neovim", name = "rose-pine", lazy = true },
	{ "olimorris/onedarkpro.nvim", lazy = true },
	{ "tanvirtin/monokai.nvim", lazy = true },
	{ "marko-cerovac/material.nvim", lazy = true },
	{ "nvim-tree/nvim-web-devicons", event = "VeryLazy" },

	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		cond = firenvim_not_active,
		config = function()
			require("config.statusline")
		end,
	},

	{
		"akinsho/bufferline.nvim",
		event = { "BufEnter" },
		cond = firenvim_not_active,
		config = function()
			require("config.bufferline")
		end,
	},

	-- fancy start screen
	{
		"nvimdev/dashboard-nvim",
		cond = firenvim_not_active,
		config = function()
			require("config.dashboard-nvim")
		end,
	},

	{
		"lukas-reineke/indent-blankline.nvim",
		event = "VeryLazy",
		config = function()
			require("config.indent-blankline")
		end,
	},

	-- Highlight URLs inside vim
	{ "itchyny/vim-highlighturl", event = "VeryLazy" },

	-- notification plugin
	{
		"rcarriga/nvim-notify",
		event = "VeryLazy",
		config = function()
			require("config.nvim-notify")
		end,
	},

	-- For Windows and Mac, we can open an URL in the browser. For Linux, it may
	-- not be possible since we maybe in a server which disables GUI.
	{
		"tyru/open-browser.vim",
		enabled = function()
			if vim.g.is_win or vim.g.is_mac then
				return true
			else
				return false
			end
		end,
		event = "VeryLazy",
	},

	-- Only install these plugins if ctags are installed on the system
	-- show file tags in vim window
	{
		"liuchengxu/vista.vim",
		enabled = function()
			if utils.executable("ctags") then
				return true
			else
				return false
			end
		end,
		cmd = "Vista",
	},

	-- Snippet engine and snippet template
	{ "SirVer/ultisnips", dependencies = {
		"honza/vim-snippets",
	}, event = "InsertEnter" },

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

	-- Comment plugin
	{ "tpope/vim-commentary", event = "VeryLazy" },

	-- Autosave files on certain events
	{ "907th/vim-auto-save", event = "InsertEnter" },

	-- Show undo history visually
	{ "simnalamburt/vim-mundo", cmd = { "MundoToggle", "MundoShow" } },

	-- better UI for some nvim actions
	{ "stevearc/dressing.nvim" },

	-- Manage your yank history
	{
		"gbprod/yanky.nvim",
		cmd = { "YankyRingHistory" },
		config = function()
			require("config.yanky")
		end,
	},

	-- Handy unix command inside Vim (Rename, Move etc.)
	{ "tpope/vim-eunuch", cmd = { "Rename", "Delete" } },

	-- Repeat vim motions
	{ "tpope/vim-repeat", event = "VeryLazy" },

	{ "nvim-zh/better-escape.vim", event = { "InsertEnter" } },

	{
		"lyokha/vim-xkbswitch",
		enabled = function()
			if vim.g.is_mac and utils.executable("xkbswitch") then
				return true
			end
			return false
		end,
		event = { "InsertEnter" },
	},

	{
		"Neur1n/neuims",
		enabled = function()
			if vim.g.is_win then
				return true
			end
			return false
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
	{ "christoomey/vim-conflicted", cmd = { "Conflicted" } },
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
	},

	-- Better git commit experience
	{ "rhysd/committia.vim", lazy = true },
	{
		"kevinhwang91/nvim-bqf",
		ft = "qf",
		config = function()
			require("config.bqf")
		end,
	},

	{
		"sindrets/diffview.nvim",
	},

	-- Faster footnote generation
	{ "vim-pandoc/vim-markdownfootnotes", ft = { "markdown" } },

	-- Vim tabular plugin for manipulate tabular, required by markdown plugins
	{ "godlygeek/tabular", cmd = { "Tabularize" } },

	{ "chrisbra/unicode.vim", event = "VeryLazy" },

	-- Additional powerful text object for vim, this plugin should be studied
	-- carefully to use its full power
	{ "wellle/targets.vim", event = "VeryLazy" },

	-- Plugin to manipulate character pairs quickly
	{ "machakann/vim-sandwich", event = "VeryLazy" },

	{ "michaeljsmith/vim-indent-object", event = "VeryLazy" },

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

	-- Since tmux is only available on Linux and Mac, we only enable these plugins
	-- for Linux and Mac
	-- .tmux.conf syntax highlighting and setting check
	{
		"christoomey/vim-tmux-navigator",
		lazy = false,
	},

	-- Modern matchit implementation
	{ "andymass/vim-matchup", event = "BufRead" },
	{ "tpope/vim-scriptease", cmd = { "Scriptnames", "Message", "Verbose" } },

	-- Asynchronous command execution
	{ "skywind3000/asyncrun.vim", lazy = true, cmd = { "AsyncRun" } },
	{ "cespare/vim-toml", ft = { "toml" }, branch = "main" },

	-- Debugger plugin
	{
		"sakhnik/nvim-gdb",
		enabled = function()
			if vim.g.is_win or vim.g.is_linux then
				return true
			end
			return false
		end,
		build = { "bash install.sh" },
		lazy = true,
	},

	-- Session management plugin
	{ "tpope/vim-obsession", cmd = "Obsession" },

	{
		"ojroques/vim-oscyank",
		enabled = function()
			if vim.g.is_linux then
				return true
			end
			return false
		end,
		cmd = { "OSCYank", "OSCYankReg" },
	},

	-- The missing auto-completion for cmdline!
	{
		"gelguy/wilder.nvim",
		build = ":UpdateRemotePlugins",
	},

	{
		"nvim-neorg/neorg",
		build = ":Neorg sync-parsers",
		dependencies = { "nvim-lua/plenary.nvim" },
		ft = { "norg" },
		config = function()
			require("config.neorg")
		end,
	},

	-- showing keybindings
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		config = function()
			require("config.which-key")
		end,
	},

	-- show and trim trailing whitespaces
	{ "jdhao/whitespace.nvim", event = "VeryLazy" },

	-- file explorer
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("config.nvim-tree")
		end,
	},

	{ "ii14/emmylua-nvim", ft = "lua" },

	{
		"j-hui/fidget.nvim",
		event = "VeryLazy",
		tag = "legacy",
		config = function()
			require("config.fidget-nvim")
		end,
	},

	{
		"mfussenegger/nvim-lint",
		auto_cmd = {
			"BufWritePost",
			"BufEnter",
		},
		config = function()
			require("config.nvim-lint")
		end,
	},
}

-- configuration for lazy itself.
local lazy_opts = {
	ui = {
		border = "rounded",
		title = "Plugin Manager",
		title_pos = "center",
	},
}

require("lazy").setup(plugin_specs, lazy_opts)
