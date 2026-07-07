vim.opt_local.textwidth = 120
vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.formatoptions:remove { "o", "r" }
vim.bo.expandtab = true
vim.bo.shiftwidth = 2
vim.bo.softtabstop = 2
vim.bo.tabstop = 2
vim.opt_local.spell = true
vim.opt_local.spelllang = "es,en"
vim.opt_local.concealcursor = "nc"

local M = {}

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

function M.toggle_concealment()
  local current_level = vim.api.nvim_get_option_value("conceallevel", { scope = "local" })
  if current_level == 0 then
    vim.api.nvim_set_option_value("conceallevel", 2, { scope = "local" })
    vim.notify("Concealment enabled", vim.log.levels.INFO)
  else
    vim.api.nvim_set_option_value("conceallevel", 0, { scope = "local" })
    vim.notify("Concealment disabled", vim.log.levels.INFO)
  end
end

_G.M = M

vim.defer_fn(disable_treesitter, 100)

local bufopts = { buffer = true, silent = true }

-- <space>l{c,v,k,e,...} = LaTeX commands (vimtex defaults are disabled)
local lp = "<space>l"
vim.keymap.set("n", lp .. "c", "<cmd>VimtexCompile<cr>", bufopts)
vim.keymap.set("n", lp .. "v", "<cmd>VimtexView<cr>", bufopts)
vim.keymap.set("n", lp .. "k", "<cmd>VimtexStop<cr>", bufopts)
vim.keymap.set("n", lp .. "e", "<cmd>VimtexErrors<cr>", bufopts)
vim.keymap.set("n", lp .. "C", "<cmd>VimtexClean<cr>", bufopts)
vim.keymap.set("n", lp .. "t", "<cmd>VimtexTocOpen<cr>", bufopts)
vim.keymap.set("n", lp .. "w", "<cmd>VimtexCountWords<cr>", bufopts)

-- spell fix: <A-l> jumps to prev misspelling and fixes with first suggestion
vim.keymap.set("i", "<A-l>", "<c-g>u<Esc>[s1z=`]a<c-g>u", bufopts)
vim.keymap.set("n", "<leader>lh", function()
  M.toggle_concealment()
end, bufopts)
vim.keymap.set("i", ";;", "\\", { buffer = true })
vim.keymap.set("i", "$$", "$$ $$<left><left><left>", { buffer = true })
