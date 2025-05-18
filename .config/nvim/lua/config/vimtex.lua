local M = {}

local function setup_keymaps()
  local keymaps = {
    { "n", "<F9>", "<plug>(vimtex-compile)", { buffer = true } },
    { "n", "<leader>ll", "<cmd>VimtexCompile<CR>", { buffer = true } },
    -- Visualización
    { "n", "<leader>lv", "<cmd>VimtexView<CR>", { buffer = true } },
    { "n", "<leader>le", "<cmd>VimtexErrors<CR>", { buffer = true } },
    -- TOC
    { "n", "<leader>lt", "<cmd>VimtexTocToggle<CR>", { buffer = true } },
    -- Limpieza
    { "n", "<leader>lc", "<cmd>VimtexClean<CR>", { buffer = true } },
    -- Otros
    { "n", "<leader>li", "<cmd>VimtexInfo<CR>", { buffer = true } },
    { "n", "<leader>lk", "<cmd>VimtexStop<CR>", { buffer = true } },
    { "n", "<leader>lK", "<cmd>VimtexStopAll<CR>", { buffer = true } },
    { "n", "<leader>lg", "<cmd>VimtexLog<CR>", { buffer = true } },
  }
  for _, map in ipairs(keymaps) do
    vim.keymap.set(unpack(map))
  end
end

local function setup_autocommands()
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "tex",
    callback = function()
      if vim.fn.exists("*vimtex#init") == 1 then
        vim.notify("VimTeX loaded successfully")
      else
        vim.notify("VimTeX not loaded!", vim.log.levels.ERROR)
      end
    end,
  })
end

local function setup_ultisnips()
  vim.g.UltiSnipsExpandTrigger = "<tab>"
  vim.g.UltiSnipsEnableSnipMate = 0
  vim.g.UltiSnipsJumpForwardTrigger = "<tab>"
  vim.g.UltiSnipsJumpBackwardTrigger = "<s-tab>"
  vim.g.UltiSnipsSnippetDirectories = { "UltiSnips", "my_snippets" }
end

function M.setup()
  vim.g.tex_flavor = "latex"
  vim.g.vimtex_view_method = "zathura"
  vim.g.vimtex_view_general_options = "--unique file:@pdf\\#src:@line@tex"

  vim.opt.conceallevel = 1
  vim.g.tex_conceal = "abdmg"

  vim.g.vimtex_compiler_method = "latexmk"
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
      "-pdf",
    },
  }

  vim.g.vimtex_compiler_progname = "nvr"
  vim.g.vimtex_compiler_enabled = 1
  vim.g.vimtex_compiler_silent = 0
  vim.g.vimtex_view_enabled = 1
  vim.g.vimtex_log_verbose = 1

  vim.g.vimtex_toc_config = {
    name = "TOC",
    layers = { "content", "todo", "include" },
    resize = 1,
    split_width = 30,
    todo_sorted = 0,
    show_help = 1,
    show_numbers = 1,
    mode = 2,
  }

  vim.g.vimtex_compiler_latexmk.root_patterns = { ".latexmkrc", "main.tex", ".git", "." }

  vim.g.vimtex_quickfix_mode = 0
  vim.g.vimtex_quickfix_enabled = 1
  vim.g.vimtex_quickfix_ignore_filters = {
    "Underfull",
    "Overfull",
    "specifier changed to",
    "Package caption Warning",
    "Package typearea Warning",
  }

  vim.g.vimtex_syntax_enabled = 1
  vim.g.vimtex_fold_enabled = 0
  vim.g.vimtex_format_enabled = 1
  vim.g.vimtex_complete_enabled = 1
  vim.g.loaded_vimtex = 1
  vim.g.vimtex_enabled = 1
  vim.g.vimtex_mappings_disable = { ["n"] = { "K" } }

  vim.g.vimtex_importer_enabled = 1

  setup_ultisnips()
  setup_autocommands()
  setup_keymaps()
end

M.setup_keymaps = setup_keymaps
M.setup_ultisnips = setup_ultisnips

return M
