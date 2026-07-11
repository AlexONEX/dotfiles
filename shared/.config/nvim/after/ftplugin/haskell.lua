vim.bo.commentstring = "-- %s"
vim.bo.expandtab = true
vim.bo.shiftwidth = 2
vim.bo.softtabstop = 2
vim.bo.tabstop = 2
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
  if vim.fn.executable("ghc") == 0 then
    vim.notify("GHC not found on the system!", vim.log.levels.ERROR)
    return
  end

  local src_path = vim.fn.expand("%:p:~")
  local src_noext = vim.fn.expand("%:p:~:r")

  create_term_buf("h", 20)
  local cmd = string.format("term ghc %s %s -o %s && %s", haskell_flags, src_path, src_noext, src_noext)
  vim.cmd(cmd)
  vim.cmd("startinsert")
end

function M.run_haskell()
  if vim.fn.executable("runhaskell") == 0 then
    vim.notify("runhaskell not found on the system!", vim.log.levels.ERROR)
    return
  end

  local src_path = vim.fn.expand("%:p:~")
  create_term_buf("h", 20)
  local cmd = string.format("term runhaskell %s", src_path)
  vim.cmd(cmd)
  vim.cmd("startinsert")
end

function M.run_hlint()
  vim.lsp.buf.code_action()
end

function M.compile_only_haskell()
  if vim.fn.executable("ghc") == 0 then
    vim.notify("GHC not found!", vim.log.levels.ERROR)
    return
  end

  local src_path = vim.fn.expand("%:p:~")
  local src_noext = vim.fn.expand("%:p:~:r")

  create_term_buf("h", 15)
  local cmd = string.format("term ghc %s %s -o %s", haskell_flags, src_path, src_noext)
  vim.cmd(cmd)
  vim.cmd("startinsert")
end

function M.run_executable()
  local exe_path = vim.fn.expand("%:p:~:r")
  if vim.fn.filereadable(exe_path) == 0 then
    vim.notify("Executable not found. Compile first!", vim.log.levels.WARN)
    return
  end

  create_term_buf("h", 15)
  local cmd = string.format("term %s", exe_path)
  vim.cmd(cmd)
  vim.cmd("startinsert")
end

local opts = { buffer = true, silent = true }
vim.keymap.set("n", "<F9>", function()
  M.compile_run_haskell()
end, opts)
vim.keymap.set("n", "<F10>", function()
  M.run_haskell()
end, opts)
vim.keymap.set("n", "<F11>", function()
  M.compile_run_haskell()
end, opts)
vim.keymap.set("n", "<F5>", function()
  M.compile_only_haskell()
end, opts)
vim.keymap.set("n", "<F6>", function()
  M.run_executable()
end, opts)
vim.keymap.set("n", "<leader>hl", function()
  M.run_hlint()
end, opts)

return M
