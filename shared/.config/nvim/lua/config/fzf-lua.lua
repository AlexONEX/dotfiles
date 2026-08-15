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

-- All files changed on this branch — committed or not. Base ref is detected
-- per-repo (upstream → origin/HEAD → HEAD); committed changes come from
-- `diff <base>...HEAD`, uncommitted from `diff HEAD` + untracked files.
local function git_changed_files()
  local function valid_ref(ref)
    return vim.system({ "git", "rev-parse", "--verify", "--quiet", ref }, { text = true }):wait().code == 0
  end
  local base
  for _, ref in ipairs { "@{upstream}", "origin/HEAD" } do
    if valid_ref(ref) then
      base = ref
      break
    end
  end
  local range = (base and base .. "...HEAD") or "HEAD"

  local files, seen = {}, {}
  local function add(cmd)
    local res = vim.system(cmd, { text = true }):wait()
    if res.code ~= 0 then
      return
    end
    for _, f in ipairs(vim.split(res.stdout, "\n")) do
      if f ~= "" and not seen[f] then
        seen[f] = true
        files[#files + 1] = f
      end
    end
  end
  add { "git", "--no-pager", "diff", "--name-only", range, "--" }
  add { "git", "--no-pager", "diff", "--name-only", "HEAD", "--" }
  add { "git", "ls-files", "-o", "--exclude-standard", "--full-name" }
  table.sort(files)

  local root = vim.trim(vim.system({ "git", "rev-parse", "--show-toplevel" }, { text = true }):wait().stdout)
  fzf.fzf_exec(files, {
    prompt = "changed files (" .. (base or "HEAD") .. ")> ",
    -- committed diff + working-tree diff, so every entry has a preview
    preview = "git diff --color=always " .. range .. " -- {-1}; git diff --color=always HEAD -- {-1}",
    actions = {
      ["enter"] = function(selected)
        vim.cmd("edit " .. vim.fn.fnameescape(root .. "/" .. selected[1]))
      end,
      ["ctrl-d"] = {
        fn = function(selected)
          local res = vim
            .system({ "git", "--no-pager", "diff", "--color=never", range, "--", selected[1] }, { text = true })
            :wait()
          if res.code ~= 0 or #res.stdout == 0 then
            return
          end
          vim.cmd("vsplit")
          local buf = vim.api.nvim_create_buf(false, true)
          vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(res.stdout, "\n"))
          vim.bo[buf].modifiable = false
          vim.bo[buf].filetype = "diff"
          vim.api.nvim_win_set_buf(0, buf)
        end,
        header = "diff vs " .. (base or "HEAD"),
      },
    },
  })
end

vim.keymap.set("n", "<leader>gd", git_changed_files, { desc = "git: all changed files (committed + uncommitted)" })

vim.keymap.set("n", "<leader>gm", "<cmd>FzfLua git_status<cr>", { desc = "git: modified files" })

vim.keymap.set("n", "<leader>ff", "<cmd>FzfLua files<cr>", { desc = "Fuzzy find files" })
vim.keymap.set("n", "<leader>fg", "<cmd>FzfLua live_grep<cr>", { desc = "Fuzzy grep files" })
vim.keymap.set("n", "<leader>fh", "<cmd>FzfLua helptags<cr>", { desc = "Fuzzy grep tags in help files" })
vim.keymap.set("n", "<leader>fb", "<cmd>FzfLua buffers<cr>", { desc = "Fuzzy search opened buffers" })
vim.keymap.set("n", "<leader>fo", "<cmd>FzfLua oldfiles<cr>", { desc = "Fuzzy search old files" })
vim.keymap.set("n", "<leader>cs", "<cmd>FzfLua lsp_document_symbols<cr>", { desc = "LSP document symbols" })
vim.keymap.set("n", "<leader>cS", "<cmd>FzfLua lsp_workspace_symbols<cr>", { desc = "LSP workspace symbols" })
vim.keymap.set("n", "<leader>cd", "<cmd>FzfLua diagnostics_document<cr>", { desc = "Document diagnostics" })
vim.keymap.set("n", "<leader>fc", "<cmd>FzfLua colorschemes<cr>", { desc = "Fuzzy find colorscheme" })
