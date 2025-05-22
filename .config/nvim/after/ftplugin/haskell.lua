vim.bo.commentstring = "-- %s"
vim.opt_local.formatoptions:remove { "o", "r" }
vim.b.matchup_enabled = 0

local haskell_flags = table.concat({
  "-Wall",
  "-Wcompat",
  "-Wincomplete-record-updates",
  "-Wincomplete-uni-patterns",
  "-Wredundant-constraints",
  "-Wmissing-export-lists",
  "-Wpartial-fields",
  "-Wmissing-deriving-strategies",
  "-Wunused-packages",
  "-Widentities",
  "-fhide-source-paths",
  "-freverse-errors",
  "-fdefer-typed-holes",
  "-fdefer-type-errors",
  "-O2",
  "-dynamic",
  "-threaded",
  "-eventlog",
  "-debug",
}, " ")

local M = {}

local function create_term_buf(type, size)
  vim.opt.splitbelow = true
  vim.opt.splitright = true
  if type == "v" then
    vim.cmd("vnew")
  else
    vim.cmd("new")
  end
  vim.cmd("resize " .. size)
end

function M.compile_run_haskell()
  local src_path = vim.fn.expand("%:p:~")
  local src_noext = vim.fn.expand("%:p:~:r")
  if vim.fn.executable("ghc") == 1 then
    create_term_buf("h", 20)
    local cmd = string.format("term ghc %s %s -o %s && %s", haskell_flags, src_path, src_noext, src_noext)
    vim.cmd(cmd)
  else
    vim.notify("GHC not found on the system!", vim.log.levels.ERROR)
    return
  end
  vim.cmd("startinsert")
end

function M.run_haskell()
  local src_path = vim.fn.expand("%:p:~")
  if vim.fn.executable("runhaskell") == 1 then
    create_term_buf("h", 20)
    local cmd = string.format("term runhaskell %s", src_path)
    vim.cmd(cmd)
  else
    vim.notify("runhaskell not found on the system!", vim.log.levels.ERROR)
    return
  end
  vim.cmd("startinsert")
end

function M.format_haskell()
  local src_path = vim.fn.expand("%:p")
  if vim.fn.executable("ormolu") == 1 then
    vim.cmd("write")
    local result = vim.fn.system(string.format("ormolu --mode inplace %s", vim.fn.shellescape(src_path)))
    if vim.v.shell_error == 0 then
      vim.cmd("edit!")
      vim.notify("File formatted successfully", vim.log.levels.INFO)
    else
      vim.notify("Error formatting file: " .. result, vim.log.levels.ERROR)
    end
  else
    vim.notify("ormolu not found on the system!", vim.log.levels.ERROR)
  end
end

function M.run_hlint()
  vim.lsp.buf.code_action()
end

_G.HaskellUtils = M

-- Use vim.keymap.set instead of vim.api.nvim_buf_set_keymap
vim.keymap.set(
  "n",
  "<F9>",
  ":lua HaskellUtils.compile_run_haskell()<CR>",
  { noremap = true, silent = true, buffer = 0 }
)
vim.keymap.set("n", "<F10>", ":lua HaskellUtils.run_haskell()<CR>", { noremap = true, silent = true, buffer = 0 })
vim.keymap.set(
  "n",
  "<F11>",
  ":lua HaskellUtils.compile_run_haskell()<CR>",
  { noremap = true, silent = true, buffer = 0 }
)
vim.keymap.set("n", "<C-s>", ":lua HaskellUtils.format_haskell()<CR>", { noremap = true, silent = true, buffer = 0 })
vim.keymap.set("n", "<leader>hl", ":lua HaskellUtils.run_hlint()<CR>", { noremap = true, silent = true, buffer = 0 })

-- LSP setup (opcional, puedes comentarlo si no lo usas)
local lspconfig = require("lspconfig")
lspconfig.hls.setup {
  settings = {
    haskell = {
      formattingProvider = "ormolu",
      checkProject = true,
    },
  },
}
