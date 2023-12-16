-- config/neomake.lua
local M = {}

M.setup = function()
  local neomake = require("neomake")

  -- Linting with neomake
  neomake.setup({
    -- You can add more general Neomake settings here if needed
  })

  -- Configure sbt maker for Scala
  vim.g.neomake_sbt_maker = {
    exe = 'sbt',
    args = {'-Dsbt.log.noformat=true', 'compile'},
    append_file = 0,
    auto_enabled = 1,
    output_stream = 'stdout',
    errorformat =
      '%E[%trror]\\ %f:%l:\\ %m,' ..
      '%-Z[error]\\ %p^,' ..
      '%-C%.%#,' ..
      '%-G%.%#'
  }

  vim.g.neomake_enabled_makers = {'sbt'}
  vim.g.neomake_verbose = 3

  -- Neomake on text change
  vim.cmd([[ autocmd InsertLeave,TextChanged * update | Neomake! sbt ]])
end

return M
