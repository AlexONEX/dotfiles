-- OpenCode AI integration
-- Keymap clashes (all remapped below):
--   go/goo    → <leader>og   (operator: send range/line to OpenCode; go is built-in vim goto)
--   ]c/[c     → ]o/[o        (diff nav: git-conflict.nvim also uses ]c/[c)
--   <S-C-u/d> → kept as-is   (free, <C-u>/<C-d> half-page scroll not mapped in this config)
--   <leader>oa/os → kept as-is (free)

vim.o.autoread = true

local opencode = require("opencode")

-- Default keymaps (no conflicts)
vim.keymap.set({ "n", "x" }, "<leader>oa", function()
  opencode.ask("@this: ")
end, { desc = "Ask OpenCode" })
vim.keymap.set({ "n", "x" }, "<leader>os", function()
  opencode.select()
end, { desc = "Select OpenCode" })

vim.keymap.set({ "n", "x" }, "<S-C-u>", function()
  opencode.command("session.half.page.up")
end, { desc = "Scroll OpenCode up" })
vim.keymap.set({ "n", "x" }, "<S-C-d>", function()
  opencode.command("session.half.page.down")
end, { desc = "Scroll OpenCode down" })

-- Remapped: go/goo → <leader>og (avoids overriding built-in go)
vim.keymap.set({ "n", "x" }, "<leader>og", function()
  return opencode.operator("@this ")
end, { desc = "Send range to OpenCode", expr = true })
vim.keymap.set("n", "<leader>ogg", function()
  return opencode.operator("@this ") .. "_"
end, { desc = "Send line to OpenCode", expr = true })

-- Remapped: ]c/[c → ]o/[o (avoids git-conflict.nvim clash)
vim.keymap.set("n", "]o", function()
  opencode.command("session.next")
end, { desc = "OpenCode: next change" })
vim.keymap.set("n", "[o", function()
  opencode.command("session.prev")
end, { desc = "OpenCode: prev change" })
