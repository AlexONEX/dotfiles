-- define function RunFile() to run current file according to its extension
function RunFile()
  if vim.bo.filetype == 'python' then
    vim.cmd('split | term python %')
  elseif vim.bo.filetype == 'c' then
    vim.cmd('!gcc && ./a.out')
  elseif vim.bo.filetype == 'cpp' then
    vim.cmd('!g++ && ./a.out')
  elseif vim.bo.filetype == 'java' then
    vim.cmd('!javac && java')
  elseif vim.bo.filetype == 'sh' then
    vim.cmd('!sh')
  elseif vim.bo.filetype == 'lua' then
    vim.cmd('!lua')
  elseif vim.bo.filetype == 'javascript' then
    vim.cmd('!node')
  elseif vim.bo.filetype == 'html' then
    vim.cmd('!thorium-browser')
  elseif vim.bo.filetype == 'css' then
    vim.cmd('!thorium-browser')
  elseif vim.bo.filetype == 'markdown' then
    vim.cmd('!thorium-browser')
  else
    vim.api.nvim_echo({ { 'filetype ' .. vim.bo.filetype .. ' is not supported', 'ErrorMsg' } }, true, {})
  end
end

-- vim options
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

vim.opt.relativenumber = true
vim.opt.guicursor = ""
vim.opt.hidden = true
vim.opt.nu = true

vim.opt.smartindent = true
vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50
vim.opt.colorcolumn = "80"

-- to disable icons and use a minimalist setup, uncomment the following
-- lvim.use_icons = false

-- general
lvim.log.level = "info"
lvim.format_on_save = {
  enabled = true,
  pattern = "*.lua",
  timeout = 1000,
}
-- Keybind for spell checking
vim.api.nvim_set_keymap("n", "<C-l>", "<c-g>u<Esc>[s1z=`]a<c-g>u",
  { noremap = true, silent = true })

-- keymappings <https://www.lunarvim.org/docs/configuration/keybindings>
-- Remove binding to enable copilot completion
lvim.leader = "space"

-- Normal Mode
-- Source current file
vim.api.nvim_set_keymap("n", "<leader>so", ":source %<CR>",
  { noremap = true, silent = true })

vim.api.nvim_set_keymap("n", "<C-x>", ":lua RunFile()<CR>",
  { noremap = true, silent = true })

-- Close current buffer
vim.keymap.set("n", "<leader>bd", function()
  vim.cmd("bd")
end)

-- Define C-y as redo
vim.keymap.set("n", "<C-y>", "<C-r>")
-- Control+f to find
vim.keymap.set("n", "<C-r>", "<cmd>Telescope find_files<CR>")
-- Control+f to find word
--vim.keymap.set("n", "<C-f>", "<cmd>Telescope live_grep<CR>")

-- Ctrl+a to select all
vim.keymap.set("n", "<C-a>", "ggVG")
vim.keymap.set('n', '<C-s>', ':w<CR>', { silent = true })
vim.keymap.set('n', '<C-v>', ':vsplit<CR>', { silent = true })
vim.keymap.set('n', '<C-h>', ':split<CR>', { silent = true })

vim.keymap.set('n', '<leader>pv', ':Ex<CR>')
vim.keymap.set('n', '<leader>y', '"+y')
vim.keymap.set('n', '<leader>p', '"+p')

vim.keymap.set('n', 'n', "mzJ`z")
vim.keymap.set('n', '<C-d>', "<C-d>zz")
vim.keymap.set('n', '<C-u>', "<C-u>zz")
vim.keymap.set('n', 'N', "Nzzzv")
vim.keymap.set('n', 'n', "nzzzv")

vim.keymap.set('n', 'Q', "<nop>")

vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")

vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")
vim.keymap.set("n", "<leader>vpp", "<cmd>e ~/.config/lvim/config.lua<CR>")

-- Visual
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Copy to clipboard and paste from clipboard
lvim.keys.visual_mode["<leader>y"] = '"+y'

-- Terminal applications
vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<CR>")
vim.keymap.set("n", "<leader>dd", "<cmd>LazyDocker<CR>")

-- Set theme settings
lvim.colorscheme = "nord"

lvim.builtin.alpha.active = true
lvim.builtin.alpha.mode = "dashboard"
lvim.builtin.terminal.active = true
lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.setup.renderer.icons.show.git = false

-- Automatically install missing parsers when entering buffer
lvim.builtin.treesitter.auto_install = true
local cmp_nvim_lsp = require "cmp_nvim_lsp"

local on_attach = function(client, bufnr)
  require("lsp_signature").on_attach()
  require("lsp-status").on_attach(client)
  require("completion").on_attach(client, bufnr)
  -- Set up keybindings specific to the LSP client
  vim.api.nvim_buf_set_keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", { silent = true })
  print("'" .. client.name .. "' server attached")
end

require("lspconfig").clangd.setup {
  on_attach = on_attach,
  capabilities = cmp_nvim_lsp.default_capabilities(),
  cmd = {
    "clangd",
    "--offset-encoding=utf-16",
  },
}

-- lvim.builtin.treesitter.ignore_install = { "haskell" }

-- -- always installed on startup, useful for parsers without a strict filetype
lvim.builtin.treesitter.ensure_installed = { "comment", "markdown_inline", "regex" }
-- -- generic LSP settings <https://www.lunarvim.org/docs/configuration/language-features/language-servers>

-- --- disable automatic installation of servers
lvim.lsp.installer.setup.automatic_installation = false

-- ---configure a server manually. IMPORTANT: Requires `:LvimCacheReset` to take effect
-- ---see the full default list `:lua =lvim.lsp.automatic_configuration.skipped_servers`
-- vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "pyright" })
-- local opts = {} -- check the lspconfig documentation for a list of all possible options
-- require("lvim.lsp.manager").setup("pyright", opts)

-- ---remove a server from the skipped list, e.g. eslint, or emmet_ls. IMPORTANT: Requires `:LvimCacheReset` to take effect
-- ---`:LvimInfo` lists which server(s) are skipped for the current filetype
-- lvim.lsp.automatic_configuration.skipped_servers = vim.tbl_filter(function(server)
--   return server ~= "emmet_ls"
-- end, lvim.lsp.automatic_configuration.skipped_servers)

-- -- you can set a custom on_attach function that will be used for all the language servers
-- -- See <https://github.com/neovim/nvim-lspconfig#keybindings-and-completion>
-- lvim.lsp.on_attach_callback = function(client, bufnr)
--   local function buf_set_option(...)
--     vim.api.nvim_buf_set_option(bufnr, ...)
--   end
--   --Enable completion triggered by <c-x><c-o>
--   buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
-- end

-- -- linters, formatters and code actions <https://www.lunarvim.org/docs/configuration/language-features/linting-and-formatting>
local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
  --   { command = "stylua" },
  {
    command = "prettier",
    extra_args = { "--print-width", "100" },
    filetypes = { "typescript", "typescriptreact" },
  },
}
-- local linters = require "lvim.lsp.null-ls.linters"
-- linters.setup {
--   { command = "flake8", filetypes = { "python" } },
--   {
--     command = "shellcheck",
--     args = { "--severity", "warning" },
--   },
-- }
-- local code_actions = require "lvim.lsp.null-ls.code_actions"
-- code_actions.setup {
--   {
--     exe = "eslint",
--     filetypes = { "typescript", "typescriptreact" },
--   },
-- }

-- -- Additional Plugins <https://www.lunarvim.org/docs/configuration/plugins/user-plugins>
lvim.plugins = {
  "shaunsingh/nord.nvim",
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "VeryLazy",
    config = function()
      require("copilot").setup({
        panel = {
          enabled = true,
          auto_refresh = false,
          keymap = {
            jump_prev = "[[",
            jump_next = "]]",
            accept = "<CR>",
            refresh = "gr",
            --open = "<M-CR>"
          },
          layout = {
            position = "bottom", -- | top | left | right
            ratio = 0.4
          },
        },
        suggestion = {
          enabled = true,
          auto_trigger = true,
          debounce = 75,
          keymap = {
            accept = "<M-l>",
            accept_word = false,
            accept_line = false,
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<C-]>",
          },
        },
        filetypes = {
          yaml = false,
          markdown = false,
          help = false,
          gitcommit = false,
          gitrebase = false,
          hgcommit = false,
          svn = false,
          cvs = false,
          ["."] = false,
        },
        copilot_node_command = 'node', -- Node.js version must be > 16.x
        server_opts_overrides = {},
      })
    end,
  },
  {
    "sirver/ultisnips",
    event = "InsertEnter",
    config = function()
      vim.g.UltiSnipsExpandTrigger = "<tab>"
      vim.g.UltiSnipsJumpForwardTrigger = "<tab>"
      vim.g.UltiSnipsJumpBackwardTrigger = "<s-tab>"
    end,
  },
  {
    "lervag/vimtex",
    event = "BufRead",
    config = function()
      vim.g.vimtex_view_method = "zathura"
      vim.g.vimtex_quickfix_mode = 0
      vim.g.vimtex_compiler_progname = "nvr"
      vim.g.vimtex_conceal = {
        math = 1,
        item = 1,
      }
      vim.g.tex_flavor = "latex"
      vim.g.tex_conceal = "abdmg"
      vim.g.vimtex_compiler_latexmk = {
        build_dir = "build",
        callback = 1,
        continuous = 1,
        executable = "latexmk",
        hooks = {},
        options = {
          "-verbose",
          "-file-line-error",
          "-synctex=1",
          "-interaction=nonstopmode",
          "-outdir=build",
        },
      }
    end,
  }
}

-- -- Autocommands (`:help autocmd`) <https://neovim.io/doc/user/autocmd.html>
vim.api.nvim_create_autocmd("FileType", {
  pattern = "zsh",
  callback = function()
    --     -- let treesitter use bash highlight for zsh files as well
    require("nvim-treesitter.highlight").attach(0, "bash")
  end,
})
