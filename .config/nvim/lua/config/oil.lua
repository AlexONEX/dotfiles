require("oil").setup {
  default_file_explorer = true,

  columns = {
    "icon",
    "permissions",
    "size",
    "mtime",
  },

  win_options = {
    wrap = false,
    signcolumn = "no",
    cursorcolumn = false,
    foldcolumn = "0",
    spell = false,
    list = false,
    conceallevel = 2,
    concealcursor = "nvic",
  },

  delete_to_trash = true,
  skip_confirm_for_simple_edits = true,

  view_options = {
    show_hidden = false,
    is_hidden_file = function(name, bufnr)
      return name:match("^%.") ~= nil
    end,
    is_always_hidden = function(name, bufnr)
      return name == "node_modules"
    end,
    sort = {
      { "type", "asc" }, -- Puts directories before files.
      { "name", "asc" }, -- Then sorts by name.
    },
  },

  keymaps = {
    ["g?"] = "actions.show_help", -- Show help
    ["<CR>"] = "actions.select", -- Open file in the current window
    ["<C-t>"] = "actions.select_tab", -- Open in a new tab
    ["<C-p>"] = "actions.preview", -- Show a file preview
    ["<C-c>"] = "actions.close", -- Close Oil
    ["<C-l>"] = "actions.refresh", -- Refresh the directory
    ["-"] = "actions.parent", -- Go up to the parent directory
    ["_"] = "actions.open_cwd", -- Open a new Oil buffer in the current working directory
    ["g."] = "actions.toggle_hidden", -- Toggle visibility of hidden files
  },

  float = {
    padding = 2,
    max_width = 0.9, -- Use a maximum of 90% of the screen width
    max_height = 0.8, -- Use a maximum of 80% of the screen height
    border = "rounded",
    win_options = {
      winblend = 0,
    },
  },
}

vim.keymap.set("n", "<space>e", function()
  require("oil").open()
end, { desc = "Open file explorer (Oil)" })

-- This keymap will open Oil in a floating window.
vim.keymap.set("n", "<space>E", function()
  require("oil").open_float()
end, { desc = "Open floating file explorer (Oil)" })
