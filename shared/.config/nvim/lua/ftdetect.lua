-- Filetype detection (migrated from ftdetect/*.vim)

vim.filetype.add {
  extension = {
    pdc = "markdown",
    snippets = "snippets",
    sonicpi = "sonicpi",
  },
  pattern = {
    [".*%.sh"] = "sh",
    [".*%.bash"] = "sh",
    [".*%.zsh"] = "sh",
    [".*%.ksh"] = "sh",
    [".*%.dash"] = "sh",
    [".*%.profile"] = "sh",
    [".*%.bashrc"] = "sh",
    [".*%.zshrc"] = "sh",
    [".zprofile"] = "sh",
  },
}

-- Set b:is_zsh / b:is_bash for relevant shell files
local shell_ft_augroup = vim.api.nvim_create_augroup("shell_filetypes", { clear = true })
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = shell_ft_augroup,
  pattern = { "*.zsh", ".zshrc", ".zprofile" },
  callback = function()
    vim.b.is_zsh = 1
  end,
})
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = shell_ft_augroup,
  pattern = { "*.bash", ".bashrc", ".bash_profile" },
  callback = function()
    vim.b.is_bash = 1
  end,
})
vim.api.nvim_create_autocmd({ "BufRead" }, {
  group = shell_ft_augroup,
  pattern = "*",
  callback = function()
    local line1 = vim.fn.getline(1)
    if line1:match("^#!.*zsh") then
      vim.b.is_zsh = 1
    elseif line1:match("^#!.*bash") then
      vim.b.is_bash = 1
    end
  end,
})

-- Sonic Pi live-coding keymaps for Ruby and Sonic Pi buffers
vim.api.nvim_create_augroup("sonic_pi", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = "sonic_pi",
  pattern = { "ruby", "sonicpi" },
  callback = function()
    vim.keymap.set("n", "<leader>sr", ":SonicRun<CR>", { buffer = true, desc = "send buffer to Sonic Pi" })
    vim.keymap.set("n", "<leader>ss", ":SonicStop<CR>", { buffer = true, desc = "stop Sonic Pi" })
    vim.keymap.set(
      "n",
      "<leader>sd",
      "<Cmd>edit /Applications/Sonic\\ Pi.app/Contents/Resources/etc/doc/tutorial/<CR>",
      { buffer = true, desc = "browse Sonic Pi tutorial docs" }
    )
  end,
})
