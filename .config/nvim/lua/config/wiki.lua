vim.g.wiki_root = "~/wiki"
vim.g.wiki_filetypes = { "md" }
vim.g.wiki_index_name = "index"
vim.g.wiki_link_creation = {
	md = {
		link_type = "md",
		url_extension = ".md",
		url_transform = function(x)
			return vim.fn["wiki#url#utils#url_encode_specific"](string.gsub(string.lower(x), "%s+", "-"), "()")
		end,
		link_text = function(url)
			return vim.fn["wiki#toc#get_page_title"](url)
		end,
	},
}
vim.g.wiki_tag_scan_num_lines = 25
vim.g.wiki_journal = {
	name = "journal",
	frequency = "daily",
	date_format = {
		daily = "%Y-%m-%d",
		weekly = "%Y_w%V",
		monthly = "%Y_m%m",
	},
}

function Create_note_with_tags()
	local wiki_root = vim.fn.expand(vim.g.wiki_root)
	if vim.fn.isdirectory(wiki_root) ~= 1 then
		vim.fn.mkdir(wiki_root, "p")
	end

	local title = vim.fn.input("Note title: ")
	if title == "" then
		print("Note creation cancelled")
		return
	end

	local tags = vim.fn.input("Tags (Example - Science:Physics:Mechanics): ")
	if tags == "" then
		print("Tags are required. Note creation cancelled")
		return
	end

	local filename = string.gsub(string.lower(title), "%s+", "-")
	local full_path = wiki_root .. "/" .. filename .. ".md"

	local lines = {
		"---",
		"title: " .. title,
		"tags: [" .. tags .. "]",
		"date: " .. os.date("%Y-%m-%d"),
		"---",
		"",
		"# " .. title,
		"",
	}

	local result = vim.fn.writefile(lines, full_path)

	if result == 0 then
		vim.cmd("edit " .. vim.fn.fnameescape(full_path))
		vim.cmd("normal! G")
		print("Note created with tags: " .. tags)
	else
		print("Failed to create note file. Error code: " .. result)
		print("Wiki root: " .. wiki_root)
		print("Full path: " .. full_path)
	end
end

vim.cmd("command! WikiCreateNoteWithTags lua Create_note_with_tags()")

vim.api.nvim_set_keymap("n", "<leader>nn", ":WikiCreateNoteWithTags<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>nt", ":WikiTagList<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>ns", ":WikiTagSearch<CR>", { noremap = true, silent = true })
