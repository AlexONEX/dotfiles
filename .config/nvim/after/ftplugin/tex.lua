-- Load VimTeX configuration if available
if vim.fn.filereadable(vim.fn.stdpath("config") .. "/lua/config/vimtex.lua") then
  local vimtex_config = require("config.vimtex")
  vimtex_config.setup()
end

-- Disable TreeSitter highlight for LaTeX files
local function disable_treesitter()
  if vim.fn.exists(":TSBufDisable") == 2 then
    vim.cmd("TSBufDisable highlight")
  else
    vim.defer_fn(function()
      if vim.fn.exists(":TSBufDisable") == 2 then
        vim.cmd("TSBufDisable highlight")
      end
    end, 500)
  end
end

-- Llamar la función con un pequeño delay para asegurar que Treesitter esté cargado
vim.defer_fn(disable_treesitter, 100)

vim.api.nvim_set_option_value("conceallevel", 2, { scope = "local" })
vim.api.nvim_set_option_value("concealcursor", "nc", { scope = "local" })

-- Buffer configuration
local function setup_buffer()
  vim.opt_local.textwidth = 120
  vim.opt_local.wrap = true
  vim.opt_local.linebreak = true
  vim.opt_local.formatoptions:remove { "o", "r" }

  -- indent
  vim.opt_local.expandtab = true
  vim.opt_local.shiftwidth = 2
  vim.opt_local.tabstop = 2
  vim.opt_local.softtabstop = 2

  -- Spell checking
  vim.opt_local.spell = true
  vim.keymap.set("i", "<A-l>", "<c-g>u<Esc>[s1z=`]a<c-g>u", { noremap = true, silent = true, buffer = true })
  vim.opt_local.spelllang = "es,en"
end

-- Format and save
local function format_and_save()
  vim.lsp.buf.format()
  vim.cmd("write")
end

local function setup_latex_keymaps()
  vim.keymap.set("n", "<C-s>", format_and_save, { buffer = true, silent = true })

  vim.keymap.set("n", "<leader>lh", function()
    local current_level = vim.api.nvim_get_option_value("conceallevel", { scope = "local" })
    if current_level == 0 then
      vim.api.nvim_set_option_value("conceallevel", 2, { scope = "local" })
      vim.notify("Concealment enabled")
    else
      vim.api.nvim_set_option_value("conceallevel", 0, { scope = "local" })
      vim.notify("Concealment disabled")
    end
  end, { buffer = true, silent = true })

  vim.keymap.set("i", ";;", "\\", { buffer = true })
  vim.keymap.set("i", "$$", "$$ $$<left><left><left>", { buffer = true })
end

setup_buffer()
setup_latex_keymaps()

vim.api.nvim_create_user_command("FormatAndSaveLatex", format_and_save, {})
