vim.bo.expandtab = true
vim.bo.shiftwidth = 4
vim.bo.softtabstop = 4
vim.bo.tabstop = 4
vim.opt_local.formatoptions:remove({ "o", "r" })

local M = {}
local utils = require("utils")

function M.format_and_save()
	if utils.executable("rustfmt") then
		vim.cmd("silent !rustfmt %")
		vim.cmd("edit")
		vim.cmd("write")
		vim.notify("Formatted with rustfmt", vim.log.levels.INFO)
	else
		vim.notify("rustfmt not found. Install Rust toolchain", vim.log.levels.WARN)
	end
end

function M.run_rust()
	vim.cmd("!cargo run")
end

function M.build_rust()
	vim.cmd("!cargo build")
end

function M.test_rust()
	vim.cmd("!cargo test")
end

function M.check_rust()
	vim.cmd("!cargo check")
end

function M.clippy_rust()
	vim.cmd("!cargo clippy")
end

_G.Ftplugin_Rust = M

local opts = { buffer = true, silent = true }
vim.keymap.set("n", "<space>f", function()
	Ftplugin_Rust.format_and_save()
end, opts)

vim.keymap.set("n", "<F9>", function()
	Ftplugin_Rust.run_rust()
end, opts)

vim.keymap.set("n", "<space>rr", function()
	Ftplugin_Rust.run_rust()
end, { buffer = true, desc = "Cargo run" })

vim.keymap.set("n", "<space>rb", function()
	Ftplugin_Rust.build_rust()
end, { buffer = true, desc = "Cargo build" })

vim.keymap.set("n", "<space>rt", function()
	Ftplugin_Rust.test_rust()
end, { buffer = true, desc = "Cargo test" })

vim.keymap.set("n", "<space>rc", function()
	Ftplugin_Rust.check_rust()
end, { buffer = true, desc = "Cargo check" })

vim.keymap.set("n", "<space>rl", function()
	Ftplugin_Rust.clippy_rust()
end, { buffer = true, desc = "Cargo clippy" })
