-- Keymaps are automatically loaded on the VeryLazy event
--
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

--- Define C-y as redo
vim.keymap.set("n", "<C-y>", "<C-r>")

-- Ctrl + a to select all
vim.keymap.set("n", "<C-a>", "ggVG")
vim.keymap.set("n", "<C-s>", ":w<CR>", { silent = true })

vim.keymap.set("n", "<leader>pv", ":Ex<CR>")

vim.keymap.set("n", "Q", "<nop>")

--exit window on escape
vim.keymap.set("n", "q", "<cmd>q!<CR>")

-- Visual
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- local Functions
function RunFile()
  if vim.bo.filetype == "python" then
    vim.cmd("split | term python %")
  elseif vim.bo.filetype == "c" then
    vim.cmd("!gcc -Wall && ./a.out")
  elseif vim.bo.filetype == "cpp" then
    vim.cmd("!g++ -Wall % && ./a.out")
  elseif vim.bo.filetype == "java" then
    vim.cmd("!javac % && java")
  elseif vim.bo.filetype == "sh" then
    vim.cmd("!sh")
  elseif vim.bo.filetype == "lua" then
    vim.cmd("!lua")
  elseif vim.bo.filetype == "javascript" then
    vim.cmd("!node")
  elseif vim.bo.filetype == "html" then
    vim.cmd("!thorium-browser")
  elseif vim.bo.filetype == "css" then
    vim.cmd("!thorium-browser")
  elseif vim.bo.filetype == "markdown" then
    vim.cmd("!thorium-browser")
  else
    vim.api.nvim_echo({ { "filetype " .. vim.bo.filetype .. " is not supported", "ErrorMsg" } }, true, {})
  end
end

vim.api.nvim_set_keymap("n", "<C-x>", ":lua RunFile()<CR>", { noremap = true, silent = true })
-- Spellcheck
vim.api.nvim_set_keymap("i", "<C-l>", "<c-g>u<Esc>[s1z=`]a<c-g>u", { noremap = true, silent = true })
