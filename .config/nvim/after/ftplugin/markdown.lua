local M = {}

vim.opt_local.concealcursor = "c"
vim.opt_local.synmaxcol = 3000
vim.opt_local.wrap = true
vim.opt_local.formatoptions:remove({ "o", "r" })

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

-- Reference link functions
function M.add_reference_at_end(label, url, title)
	vim.schedule(function()
		local bufnr = vim.api.nvim_get_current_buf()
		local line_count = vim.api.nvim_buf_line_count(bufnr)
		-- Prepare reference definition
		local ref_def = "[" .. label .. "]: " .. url
		if title and title ~= "" then
			ref_def = ref_def .. ' "' .. title .. '"'
		end
		-- Check if references section exists
		local buffer_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
		local has_ref_section = false
		for _, line in ipairs(buffer_lines) do
			if line:match("^%s*<!%-%-.*[Rr]eferences.*%-%->[%s]*$") then
				has_ref_section = true
				break
			end
		end
		local lines_to_add = {}
		-- Add references header if it doesn't exist
		if not has_ref_section then
			if #lines_to_add == 0 then
				table.insert(lines_to_add, "")
			end
			table.insert(lines_to_add, "<!-- References -->")
		end
		table.insert(lines_to_add, ref_def)
		-- Insert at buffer end
		vim.api.nvim_buf_set_lines(bufnr, line_count, line_count, false, lines_to_add)
	end)
end

function M.get_ref_link_labels()
	local labels = {}
	local seen = {} -- To avoid duplicates
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	for _, line in ipairs(lines) do
		-- Pattern explanation:
		-- %[.-%] matches [link text] (non-greedy)
		-- %[(.-)%] matches [label] and captures the label content
		local start_pos = 1
		while start_pos <= #line do
			local match_start, match_end, label = string.find(line, "%[.-%]%[(.-)%]", start_pos)
			if not match_start then
				break
			end
			-- Only add unique labels
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
	-- Remove leading spaces first
	local trimmed = str:match("^%s*(.*)")
	local count = 0
	-- Count each sequence of one or more consecutive spaces
	for spaces in trimmed:gmatch("%s+") do
		count = count + 1
	end
	return count
end

local function setup_keymaps()
	vim.api.nvim_buf_set_keymap(
		0,
		"n",
		"+",
		":set operatorfunc=v:lua.MarkdownUtils.add_list_symbol<CR>g@",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		0,
		"x",
		"+",
		':<C-U>lua MarkdownUtils.add_list_symbol(vim.fn.line("\'<"), vim.fn.line("\'>"))<CR>',
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		0,
		"n",
		"\\",
		":set operatorfunc=v:lua.MarkdownUtils.add_line_break<CR>g@",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		0,
		"x",
		"\\",
		':<C-U>lua MarkdownUtils.add_line_break(vim.fn.line("\'<"), vim.fn.line("\'>"))<CR>',
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		0,
		"n",
		"<C-s>",
		":lua MarkdownUtils.format_and_save()<CR>",
		{ noremap = true, silent = true }
	)
	if vim.fn.exists(":FootnoteNumber") == 1 then
		vim.api.nvim_buf_set_keymap(
			0,
			"n",
			"^^",
			":<C-U>call markdownfootnotes#VimFootnotes('i')<CR>",
			{ noremap = true, silent = true }
		)
		vim.api.nvim_buf_set_keymap(
			0,
			"i",
			"^^",
			"<C-O>:<C-U>call markdownfootnotes#VimFootnotes('i')<CR>",
			{ noremap = true, silent = true }
		)
		vim.api.nvim_buf_set_keymap(0, "i", "@@", "<Plug>ReturnFromFootnote", { silent = true })
		vim.api.nvim_buf_set_keymap(0, "n", "@@", "<Plug>ReturnFromFootnote", { silent = true })
	end
	vim.api.nvim_buf_set_keymap(
		0,
		"n",
		"<Space>mc",
		":lua MarkdownUtils.insert_code_block()<CR>",
		{ noremap = true, silent = true }
	)
	-- Text objects for Markdown code blocks
	vim.api.nvim_buf_set_keymap(
		0,
		"x",
		"ic",
		":<C-U>lua require('text_obj').MdCodeBlock('i')<CR>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		0,
		"x",
		"ac",
		":<C-U>lua require('text_obj').MdCodeBlock('a')<CR>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		0,
		"o",
		"ic",
		":<C-U>lua require('text_obj').MdCodeBlock('i')<CR>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		0,
		"o",
		"ac",
		":<C-U>lua require('text_obj').MdCodeBlock('a')<CR>",
		{ noremap = true, silent = true }
	)
end

function M.setup()
	setup_keymaps()

	-- Set up the AddRef command
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
			vim.print(string.format("arg_lead: '%s', cmdline: '%s', curpos: %d", arg_lead, cmdline, curpos))
			-- only complete the first argument
			if count_consecutive_spaces(cmdline) > 1 then
				-- we are now starting the second argument, so no completion anymore
				return {}
			end
			local ref_link_labels = M.get_ref_link_labels()
			return ref_link_labels
		end,
	})
end

_G.MarkdownUtils = M
return M
