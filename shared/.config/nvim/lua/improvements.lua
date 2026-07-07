local search_count_extmark_id

local function show_search_index()
  -- Only proceed if there's an active search
  local searchCount = vim.fn.searchcount { recompute = 1, maxcount = 0 }
  if searchCount.current == 0 or searchCount.total == 0 then
    return
  end

  local namespaceId = vim.api.nvim_create_namespace("search")
  vim.api.nvim_buf_clear_namespace(0, namespaceId, 0, -1)

  search_count_extmark_id = vim.api.nvim_buf_set_extmark(0, namespaceId, vim.api.nvim_win_get_cursor(0)[1] - 1, 0, {
    virt_text = { { "[" .. searchCount.current .. "/" .. searchCount.total .. "]", "StatusLine" } },
    virt_text_pos = "eol",
  })

  -- Use pcall to handle potential errors with redraw
  pcall(function()
    vim.cmd("redraw")
  end)
end

local keys = { "n", "N", "*", "#", "g*", "g#" }
for _, key in ipairs(keys) do
  vim.keymap.set("n", key, function()
    vim.cmd("normal! " .. key)
    show_search_index()
  end, { noremap = true })
end

local group = vim.api.nvim_create_augroup("SearchIndex", { clear = true })
vim.api.nvim_create_autocmd("CmdlineLeave", {
  group = group,
  callback = function(event)
    if event.match == "/" or event.match == "?" then
      -- Delay slightly to let the search execute
      vim.defer_fn(function()
        pcall(show_search_index)
      end, 10)
    end
  end,
})
