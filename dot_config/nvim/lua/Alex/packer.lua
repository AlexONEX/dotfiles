-- This file can be loaded by calling `lua require('plugins')` from your init.vim
-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]
return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'github/copilot.vim'
  use 'wbthomason/packer.nvim'
  use { 'nvim-telescope/telescope.nvim',
  	tag = '0.1.1',
	requires = {
		{'nvim-lua/plenary.nvim'}
	}
  }
  use ({
	'shaunsingh/nord.nvim',
	config = function()
		vim.cmd('colorscheme nord')
	end
  })
  use (
	  'nvim-treesitter/nvim-treesitter',
	  {run = ':TSUpdate'}
  )
  --use 'nvim-treesitter/playground'
  use 'ThePrimeagen/harpoon'
  use 'mbbill/undotree'
  use("tpope/vim-fugitive")

  use {
	  'VonHeikemen/lsp-zero.nvim',
	  branch = 'v1.x',
	  requires = {
		  -- LSP Support
		  {'neovim/nvim-lspconfig'},
		  {'williamboman/mason.nvim'},
		  {'williamboman/mason-lspconfig.nvim'},

		  -- Autocompletion
		  {'hrsh7th/nvim-cmp'},
		  {'hrsh7th/cmp-buffer'},
		  {'hrsh7th/cmp-path'},
		  {'saadparwaiz1/cmp_luasnip'},
		  {'hrsh7th/cmp-nvim-lsp'},
		  {'hrsh7th/cmp-nvim-lua'},

		  -- Snippets
		  {'L3MON4D3/LuaSnip'},
		  {'rafamadriz/friendly-snippets'},
	  }
  }
  -- add lualine
  use {
      'hoob3rt/lualine.nvim',
      requires = {'kyazdani42/nvim-web-devicons', opt = true}
  }
  use 'lambdalisue/suda.vim'
  use 'lervag/vimtex'
end )
