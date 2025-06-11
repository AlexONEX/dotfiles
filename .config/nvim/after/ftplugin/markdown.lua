vim.opt_local.concealcursor = "c"
vim.opt_local.synmaxcol = 3000
vim.opt_local.wrap = true
vim.opt_local.formatoptions:remove({ "o", "r" })

local M = {}

function M.add_list_symbol(start_line, end_line)
	for line = start_line, end_line do
		local text = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1]
		local indent = text:match("^%s*")
		local new_text = indent .. "+ " .. text:sub(#indent + 1)
		vim.api.nvim_buf_set_lines(0, line - 1, line, false, { new_text })
	end
end

function M.add_line_break(start_line, end_line)
	for line = start_line, end_line do
		local text = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1]
		vim.api.nvim_buf_set_lines(0, line - 1, line, false, { text .. "\\" })
	end
end

function M.format_and_save()
	vim.lsp.buf.format()
	vim.cmd("write")
end

function M.insert_code_block()
	vim.api.nvim_put({ "```", "", "```" }, "l", true, true)
	vim.api.nvim_win_set_cursor(0, { vim.api.nvim_win_get_cursor(0)[1] + 1, 0 })
	vim.cmd("startinsert!")
end

function M.add_reference_at_end(label, url, title)
	vim.schedule(function()
		local bufnr = vim.api.nvim_get_current_buf()
		local line_count = vim.api.nvim_buf_line_count(bufnr)
		local ref_def = "[" .. label .. "]: " .. url
		if title and title ~= "" then
			ref_def = ref_def .. ' "' .. title .. '"'
		end
		local buffer_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
		local has_ref_section = false
		for _, line in ipairs(buffer_lines) do
			if line:match("^%s*<!%-%-.*[Rr]eferences.*%-%->[%s]*$") then
				has_ref_section = true
				break
			end
		end
		local lines_to_add = {}
		if not has_ref_section then
			if #lines_to_add == 0 then
				table.insert(lines_to_add, "")
			end
			table.insert(lines_to_add, "<!-- References -->")
		end
		table.insert(lines_to_add, ref_def)
		vim.api.nvim_buf_set_lines(bufnr, line_count, line_count, false, lines_to_add)
	end)
end

function M.get_ref_link_labels()
	local labels = {}
	local seen = {}
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	for _, line in ipairs(lines) do
		local start_pos = 1
		while start_pos <= #line do
			local match_start, match_end, label = string.find(line, "%[.-%]%[(.-)%]", start_pos)
			if not match_start then
				break
			end
			if label and label ~= "" and not seen[label] then
				table.insert(labels, label)
				seen[label] = true
			end
			start_pos = match_end + 1
		end
	end
	return labels
end

local function count_consecutive_spaces(str)
	local trimmed = str:match("^%s*(.*)")
	local count = 0
	for spaces in trimmed:gmatch("%s+") do
		count = count + 1
	end
	return count
end

local function setup_keymaps()
	local opts = { buffer = true, silent = true }

	vim.keymap.set("n", "+", ":set operatorfunc=v:lua.Ftplugin_Markdown.add_list_symbol<CR>g@", opts)
	vim.keymap.set(
		"x",
		"+",
		':<C-U>lua Ftplugin_Markdown.add_list_symbol(vim.fn.line("\'<"), vim.fn.line("\'>"))<CR>',
		opts
	)
	vim.keymap.set("n", "\\", ":set operatorfunc=v:lua.Ftplugin_Markdown.add_line_break<CR>g@", opts)
	vim.keymap.set(
		"x",
		"\\",
		':<C-U>lua Ftplugin_Markdown.add_line_break(vim.fn.line("\'<"), vim.fn.line("\'>"))<CR>',
		opts
	)
	vim.keymap.set("n", "<C-s>", function()
		Ftplugin_Markdown.format_and_save()
	end, opts)
	vim.keymap.set("n", "<space>mc", function()
		Ftplugin_Markdown.insert_code_block()
	end, opts)

	if vim.fn.exists(":FootnoteNumber") == 1 then
		vim.keymap.set("n", "^^", ":<C-U>call markdownfootnotes#VimFootnotes('i')<CR>", opts)
		vim.keymap.set("i", "^^", "<C-O>:<C-U>call markdownfootnotes#VimFootnotes('i')<CR>", opts)
		vim.keymap.set("i", "@@", "<Plug>ReturnFromFootnote", { buffer = true })
		vim.keymap.set("n", "@@", "<Plug>ReturnFromFootnote", { buffer = true })
	end

	vim.keymap.set("x", "ic", ":<C-U>lua require('text_obj').MdCodeBlock('i')<CR>", opts)
	vim.keymap.set("x", "ac", ":<C-U>lua require('text_obj').MdCodeBlock('a')<CR>", opts)
	vim.keymap.set("o", "ic", ":<C-U>lua require('text_obj').MdCodeBlock('i')<CR>", opts)
	vim.keymap.set("o", "ac", ":<C-U>lua require('text_obj').MdCodeBlock('a')<CR>", opts)
end

function M.setup()
	setup_keymaps()

	vim.api.nvim_buf_create_user_command(0, "AddRef", function(opts)
		local args = vim.split(opts.args, " ", { trimempty = true })
		if #args < 2 then
			vim.print("Usage: :AddRef <label> <url>")
			return
		end
		local label = args[1]
		local url = args[2]
		M.add_reference_at_end(label, url, "")
	end, {
		desc = "Add reference link at buffer end",
		nargs = "+",
		complete = function(arg_lead, cmdline, curpos)
			if count_consecutive_spaces(cmdline) > 1 then
				return {}
			end
			return M.get_ref_link_labels()
		end,
	})
end

_G.Ftplugin_Markdown = M
M.setup()
