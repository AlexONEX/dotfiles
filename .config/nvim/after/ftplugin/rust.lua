vim.bo.commentstring = "// %s"
vim.opt_local.formatoptions:remove({ "o", "r" })
vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4
vim.opt_local.softtabstop = 4
vim.opt_local.expandtab = true
vim.g.rustfmt_autosave = 1

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

function M.compile_run_rust()
	local src_path = vim.fn.expand("%:p")
	local src_dir = vim.fn.expand("%:p:h")
	local src_name = vim.fn.expand("%:t:r")
	if vim.fn.executable("cargo") ~= 1 then
		vim.notify("Cargo is not found on the system!", vim.log.levels.ERROR)
		return
	end
	create_term_buf("h", 20)
	if vim.fn.filereadable(src_dir .. "/Cargo.toml") == 1 then
		local cmd = string.format("term cd %s && cargo run", vim.fn.shellescape(src_dir))
		vim.cmd(cmd)
	else
		local output_path = vim.fn.shellescape(src_dir .. "/" .. src_name)
		local cmd = string.format("term rustc %s -o %s && %s", vim.fn.shellescape(src_path), output_path, output_path)
		vim.cmd(cmd)
	end
	vim.cmd("startinsert")
end

function M.compile_run_rust_test()
	local src_dir = vim.fn.expand("%:p:h")
	if vim.fn.executable("cargo") ~= 1 then
		vim.notify("Cargo is not found on the system!", vim.log.levels.ERROR)
		return
	end
	create_term_buf("h", 20)
	local cmd = string.format("term cd %s && cargo test", vim.fn.shellescape(src_dir))
	vim.cmd(cmd)
	vim.cmd("startinsert")
end

function M.format_rust()
	vim.lsp.buf.format()
end

_G.Ftplugin_Rust = M

vim.keymap.set("n", "<F9>", ":lua Ftplugin_Rust.compile_run_rust()<CR>", { noremap = true, silent = true, buffer = 0 })
vim.keymap.set("n", "<F11>", ":lua Ftplugin_Rust.compile_run_rust()<CR>", { noremap = true, silent = true, buffer = 0 })
vim.keymap.set("n", "<C-s>", ":lua Ftplugin_Rust.format_rust()<CR>", { noremap = true, silent = true, buffer = 0 })

vim.api.nvim_buf_create_user_command(0, "RustTest", function()
	M.compile_run_rust_test()
end, { desc = "Run Rust tests" })
