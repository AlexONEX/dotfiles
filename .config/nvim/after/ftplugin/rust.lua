-- General configuration
vim.bo.commentstring = "// %s"
vim.opt_local.formatoptions:remove { "o", "r" }

local M = {}

-- Function to create a terminal buffer
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

-- Function to compile and run Rust
function M.compile_run_rust()
  local src_path = vim.fn.expand("%:p")
  local src_dir = vim.fn.expand("%:p:h")
  local src_name = vim.fn.expand("%:t:r")
  if vim.fn.executable("cargo") ~= 1 then
    vim.api.nvim_err_writeln("Cargo is not found on the system!")
    return
  end
  create_term_buf("h", 20)
  -- Check if we're in a Cargo project
  if vim.fn.filereadable(src_dir .. "/Cargo.toml") == 1 then
    -- Run with Cargo
    local cmd = string.format("term cd %s && cargo run", vim.fn.shellescape(src_dir))
    vim.cmd(cmd)
  else
    -- Compile and run as a single file
    local output_path = vim.fn.shellescape(src_dir .. "/" .. src_name)
    local cmd = string.format("term rustc %s -o %s && %s", vim.fn.shellescape(src_path), output_path, output_path)
    vim.cmd(cmd)
  end
  vim.cmd("startinsert")
end

-- Function to run Rust tests
function M.compile_run_rust_test()
  local src_dir = vim.fn.expand("%:p:h")
  if vim.fn.executable("cargo") ~= 1 then
    vim.api.nvim_err_writeln("Cargo is not found on the system!")
    return
  end
  create_term_buf("h", 20)
  local cmd = string.format("term cd %s && cargo test", vim.fn.shellescape(src_dir))
  vim.cmd(cmd)
  vim.cmd("startinsert")
end

-- Make the functions available globally with a namespace
_G.RustUtils = M

-- Key mappings
vim.api.nvim_buf_set_keymap(0, "n", "<F9>", ":lua RustUtils.compile_run_rust()<CR>", { noremap = true, silent = true })
vim.api.nvim_buf_set_keymap(0, "n", "<F11>", ":lua RustUtils.compile_run_rust()<CR>", { noremap = true, silent = true })
vim.api.nvim_buf_set_keymap(0, "n", "<C-s>", ":lua vim.lsp.buf.format()<CR>", { noremap = true, silent = true })

-- Rust-specific settings
vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4
vim.opt_local.softtabstop = 4
vim.opt_local.expandtab = true

-- Optional: Set up specific linters or formatting tools for Rust
vim.g.rustfmt_autosave = 1

-- Optional: Add Rust-specific commands
vim.cmd([[command! RustTest lua RustUtils.compile_run_rust_test()]])

return M
