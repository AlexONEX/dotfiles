local M = {}

local search_count_extmark_id
local function show_search_index()
	local namespaceId = vim.api.nvim_create_namespace("search")
	vim.api.nvim_buf_clear_namespace(0, namespaceId, 0, -1)
	local searchCount = vim.fn.searchcount()
	search_count_extmark_id = vim.api.nvim_buf_set_extmark(0, namespaceId, vim.api.nvim_win_get_cursor(0)[1] - 1, 0, {
		virt_text = { { "[" .. searchCount.current .. "/" .. searchCount.total .. "]", "StatusLine" } },
		virt_text_pos = "eol",
	})
	vim.cmd("redraw")
end

local function clear_search_index()
	local namespaceId = vim.api.nvim_get_namespaces()["search"]
	if namespaceId and search_count_extmark_id then
		vim.api.nvim_buf_del_extmark(0, namespaceId, search_count_extmark_id)
	end
end

local function clear_search_highlight_and_index()
	clear_search_index()
	vim.cmd("nohlsearch")
end

local keys = { "n", "N", "*", "#", "g*", "g#" }
for _, key in ipairs(keys) do
	vim.keymap.set("n", key, function()
		vim.cmd("normal! " .. key)
		show_search_index()
	end, { noremap = true })
end

vim.keymap.set("n", "<Esc>", function()
	clear_search_highlight_and_index()
end, { noremap = true })

local group = vim.api.nvim_create_augroup("SearchIndex", { clear = true })
vim.api.nvim_create_autocmd("CmdlineLeave", {
	group = group,
	callback = function(event)
		if event.match == "/" or event.match == "?" then
			show_search_index()
		end
	end,
})

M.show_search_index = show_search_index
M.clear_search_index = clear_search_index
M.clear_search_highlight_and_index = clear_search_highlight_and_index

return M
