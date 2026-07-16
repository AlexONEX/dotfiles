local parsers = {
  "python",
  "cpp",
  "c",
  "lua",
  "vim",
  "vimdoc",
  "json",
  "toml",
  "yaml",
  "sql",
  "markdown",
  "markdown_inline",
  "haskell",
  "rust",
  "bash",
  "typescript",
  "javascript",
  "tsx",
  "terraform",
  "hcl",
}

-- Install missing parsers asynchronously
vim.schedule(function()
  local cfg = require("nvim-treesitter.config")
  local installed_set = {}
  for _, p in ipairs(cfg.get_installed("parsers")) do
    installed_set[p] = true
  end
  local missing = vim.tbl_filter(function(p)
    return not installed_set[p]
  end, parsers)
  if #missing > 0 then
    require("nvim-treesitter.install").install(missing)
  end
end)

-- Disable treesitter for files > 100KB
vim.api.nvim_create_autocmd("BufReadPre", {
  callback = function(args)
    local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(args.buf))
    if ok and stats and stats.size > 100 * 1024 then
      vim.b[args.buf].ts_large_file = true
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    if vim.b[args.buf] and vim.b[args.buf].ts_large_file then
      pcall(vim.treesitter.stop, args.buf)
    end
  end,
})

-- Context-aware comments for TSX: cursor inside JSX → {/* */}
local comment_timer = assert(vim.uv.new_timer())
local comment_debounce_ms = 50

vim.api.nvim_create_autocmd("CursorMoved", {
  pattern = { "*.tsx", "*.jsx", "*.ts", "*.js" },
  callback = function()
    comment_timer:stop()
    comment_timer:start(
      comment_debounce_ms,
      0,
      vim.schedule_wrap(function()
        local ok, ts_utils = pcall(require, "nvim-treesitter.ts_utils")
        if not ok then
          return
        end
        local node = ts_utils.get_node_at_cursor()
        if not node then
          return
        end
        local current = node
        while current do
          if current:type():match("jsx") then
            vim.bo.commentstring = "{/* %s */}"
            return
          end
          current = current:parent()
        end
        vim.bo.commentstring = "// %s"
      end)
    )
  end,
})

-- ─── Textobjects (nvim-treesitter-textobjects) ─────────────────────────────
-- Select (af/if/ac/ic) handled by mini.ai — not mapped here.
-- Move: jump between functions/classes in normal mode
--   ]f/[f = next/prev function, ]c/[c = next/prev class
local move_map = {
  ["]f"] = { fn = "goto_next_start", query = "@function.outer" },
  ["[f"] = { fn = "goto_previous_start", query = "@function.outer" },
  ["]c"] = { fn = "goto_next_start", query = "@class.outer" },
  ["[c"] = { fn = "goto_previous_start", query = "@class.outer" },
}
for lhs, spec in pairs(move_map) do
  vim.keymap.set("n", lhs, function()
    require("nvim-treesitter-textobjects.move")[spec.fn](spec.query, "textobjects")
  end, { desc = lhs:sub(2) .. " " .. spec.query:match("@(%w+)"):gsub("_", " ") })
end
