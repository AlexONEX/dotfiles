-- :SudaRead Read file with sudo
-- :SudaWrite Write file with sudo
-- Define keybindings to use this plugin
-- <leader>rw :SudaWrite
-- <leader>rr :SudaRead
vim.keymap.set("n", "<leader>rw", ":SudaWrite<CR>", {noremap = true})
vim.keymap.set("n", "<leader>rr", ":SudaRead<CR>", {noremap = true})
