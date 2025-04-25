local keymap = vim.keymap

vim.g.neoformat_basic_format_align = 1
vim.g.neoformat_basic_format_retab = 1
vim.g.neoformat_basic_format_trim = 1
vim.g.neoformat_only_msg_on_error = 1

vim.g.neoformat_enabled_python = { "ruff_format", "ruff_fix" }
vim.g.neoformat_enabled_lua = { "stylua" }
vim.g.neoformat_enabled_rust = { "rustfmt" }
vim.g.neoformat_enabled_c = { "clang-format" }
vim.g.neoformat_enabled_cpp = { "clang-format" }
vim.g.neoformat_enabled_sh = { "shfmt" }
vim.g.neoformat_enabled_bash = { "shfmt" }
vim.g.neoformat_enabled_zsh = { "shfmt" }
vim.g.neoformat_enabled_markdown = { "prettier" }
vim.g.neoformat_enabled_haskell = { "fourmolu", "brittany" }

keymap.set("n", "<space>f", ":Neoformat<CR>", { desc = "Format current file" })

local format_augroup = vim.api.nvim_create_augroup("FormatAutogroup", { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = { "*.py", "*.lua", "*.rs", "*.c", "*.cpp", "*.h", "*.sh", "*.bash", "*.zsh", "*.md", "*.hs" },
	callback = function()
		vim.cmd("Neoformat")
	end,
	group = format_augroup,
})

-- shell
vim.g.neoformat_sh_shfmt = {
	exe = "shfmt",
	args = "-i 2 -ci",
	stdin = 1,
}

vim.g.neoformat_bash_shfmt = vim.g.neoformat_sh_shfmt
vim.g.neoformat_zsh_shfmt = vim.g.neoformat_sh_shfmt

-- stylua
vim.g.neoformat_lua_stylua = {
	exe = "stylua",
	args = "--indent-type Spaces --indent-width 2 -",
	stdin = 1,
}

-- ruff
vim.g.neoformat_python_ruff_format = {
	exe = "ruff",
	args = 'format --stdin-filename "%:p" -',
	stdin = 1,
}

vim.g.neoformat_python_ruff_fix = {
	exe = "ruff",
	args = '--fix --stdin-filename "%:p" -',
	stdin = 1,
}
