local parsers = {
  "python", "cpp", "c", "lua", "vim", "vimdoc",
  "json", "toml", "yaml", "latex", "sql", "bibtex",
  "markdown", "markdown_inline", "haskell", "rust", "bash",
  "typescript", "javascript", "tsx", "terraform", "hcl",
}

-- Install missing parsers asynchronously
vim.schedule(function()
  local cfg = require("nvim-treesitter.config")
  local installed_set = {}
  for _, p in ipairs(cfg.get_installed("parsers")) do
    installed_set[p] = true
  end
  local missing = vim.tbl_filter(function(p) return not installed_set[p] end, parsers)
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
