local fzf = require("fzf-lua")

fzf.register_ui_select()

fzf.setup {
  defaults = {
    file_icons = "mini",
  },
  winopts = {
    row = 0.5,
    height = 0.7,
  },
  keymap = {
    builtin = {
      ["<C-j>"] = "preview-down",
      ["<C-k>"] = "preview-up",
    },
  },
  files = {
    previewer = false,
  },
}

-- Project switcher: find git repos under ~/Github
local function project_files()
  local handle = io.popen("find ~/Github -maxdepth 3 -name '.git' -type d 2>/dev/null")
  if not handle then
    return
  end
  local repos = {}
  for line in handle:lines() do
    local root = line:gsub("/%.git$", "")
    repos[#repos + 1] = root
  end
  handle:close()

  if #repos == 0 then
    vim.notify("No git repos found under ~/Github", vim.log.levels.WARN)
    return
  end

  fzf.fzf_exec(repos, {
    prompt = "Projects> ",
    actions = {
      ["enter"] = function(selected)
        if selected and selected[1] then
          vim.cmd("tcd " .. selected[1])
          vim.notify("Switched to: " .. selected[1], vim.log.levels.INFO)
        end
      end,
    },
  })
end

vim.keymap.set("n", "<leader>fp", project_files, { desc = "Switch project" })

vim.keymap.set("n", "<leader>ff", "<cmd>FzfLua files<cr>", { desc = "Fuzzy find files" })
vim.keymap.set("n", "<leader>fg", "<cmd>FzfLua live_grep<cr>", { desc = "Fuzzy grep files" })
vim.keymap.set("n", "<leader>fh", "<cmd>FzfLua helptags<cr>", { desc = "Fuzzy grep tags in help files" })
vim.keymap.set("n", "<leader>fb", "<cmd>FzfLua buffers<cr>", { desc = "Fuzzy search opened buffers" })
vim.keymap.set("n", "<leader>fo", "<cmd>FzfLua oldfiles<cr>", { desc = "Fuzzy search old files" })
vim.keymap.set("n", "<space>cs", "<cmd>FzfLua lsp_document_symbols<cr>", { desc = "LSP document symbols" })
vim.keymap.set("n", "<space>cS", "<cmd>FzfLua lsp_workspace_symbols<cr>", { desc = "LSP workspace symbols" })
vim.keymap.set("n", "<space>cd", "<cmd>FzfLua diagnostics_document<cr>", { desc = "Document diagnostics" })
vim.keymap.set("n", "<leader>fc", "<cmd>FzfLua colorschemes<cr>", { desc = "Fuzzy find colorscheme" })
