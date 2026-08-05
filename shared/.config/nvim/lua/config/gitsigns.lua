local gs = require("gitsigns")

gs.setup {
  signs = {
    add = { text = "+" },
    change = { text = "~" },
    delete = { text = "_" },
    topdelete = { text = "‾" },
    changedelete = { text = "│" },
  },
  word_diff = false,
  on_attach = function(bufnr)
    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map("n", "]g", function()
      if vim.wo.diff then
        return "]g"
      end
      vim.schedule(function()
        gs.nav_hunk("next")
      end)
      return "<Ignore>"
    end, { expr = true, desc = "next hunk" })

    map("n", "[g", function()
      if vim.wo.diff then
        return "[g"
      end
      vim.schedule(function()
        gs.nav_hunk("prev")
      end)
      return "<Ignore>"
    end, { expr = true, desc = "previous hunk" })

    -- Actions (under <leader>gh = "hunks", keeps <leader>g{s,p,b,d} free for
    -- fugitive/gitlinker which are global and would otherwise be shadowed here)
    map("n", "<leader>ghs", gs.stage_hunk, { desc = "stage hunk" })
    map("n", "<leader>ghr", gs.reset_hunk, { desc = "reset hunk" })
    map("v", "<leader>ghs", function()
      gs.stage_hunk { vim.fn.line("."), vim.fn.line("v") }
    end, { desc = "stage hunk" })
    map("v", "<leader>ghr", function()
      gs.reset_hunk { vim.fn.line("."), vim.fn.line("v") }
    end, { desc = "reset hunk" })
    map("n", "<leader>ghS", gs.stage_buffer, { desc = "stage buffer" })
    map("n", "<leader>ghu", gs.undo_stage_hunk, { desc = "undo stage hunk" })
    map("n", "<leader>ghd", gs.diffthis, { desc = "diff this" })
    map("n", "<leader>ghp", gs.preview_hunk, { desc = "preview hunk" })
    map("n", "<leader>ghb", function()
      gs.blame_line { full = true }
    end, { desc = "blame line" })
  end,
}

vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    vim.cmd([[
      hi GitSignsChangeInline gui=reverse
      hi GitSignsAddInline gui=reverse
      hi GitSignsDeleteInline gui=reverse
    ]])
  end,
})
