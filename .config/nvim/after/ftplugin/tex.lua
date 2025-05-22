-- Load VimTeX configuration if available
if vim.fn.filereadable(vim.fn.stdpath("config") .. "/lua/config/vimtex.lua") then
  local vimtex_config = require("config.vimtex")
  vimtex_config.setup()
end

-- Disable TreeSitter highlight for LaTeX files (para que funcione concealment de VimTeX)
vim.cmd("TSBufDisable highlight")

-- Configurar concealment específico para LaTeX
vim.api.nvim_set_option_value("conceallevel", 2, { scope = "local" })
vim.api.nvim_set_option_value("concealcursor", "nc", { scope = "local" })

-- Buffer configuration
local function setup_buffer()
  -- Configuración de texto y formato
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

-- Configurar keymaps genéricos para LaTeX
local function setup_latex_keymaps()
  -- Guardar y formatear
  vim.keymap.set("n", "<C-s>", format_and_save, { buffer = true, silent = true })

  -- Toggle concealment específico para este buffer
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

  -- Snippets y completion (si no usas VimTeX para esto)
  vim.keymap.set("i", ";;", "\\", { buffer = true })
  vim.keymap.set("i", "$$", "$$ $$<left><left><left>", { buffer = true })
end

setup_buffer()
setup_latex_keymaps()

vim.api.nvim_create_user_command("FormatAndSaveLatex", format_and_save, {})
