local opts = {
  dir = "~/wiki",

  new_notes_location = "current_dir",

  note_id_func = function(title)
    if title and title ~= "" then
      return title:gsub("%s+", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
    else
      return os.date("%Y%m%d%H%M%S")
    end
  end,

  daily_notes = {
    folder = "journal",
    date_format = "%Y-%m-%d",
    template = "daily.md",
  },

  completion = {
    nvim_cmp = true,
    min_chars = 2,
  },

  ui = {
    enable = true,
  },
}

require("obsidian").setup(opts)

local function CreateParaNote(para_type)
  local vault_path = vim.fn.expand(opts.dir)

  local title = vim.fn.input(para_type .. " Title: ")
  if title == "" or title == nil then
    vim.notify("Note creation canceled.", vim.log.levels.WARN)
    return
  end

  local additional_tags = vim.fn.input("Additional tags (e.g., Hobbies:Gaming:Steam): ")

  local filename = title:gsub("%s+", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
  local full_path = vault_path .. "/" .. filename .. ".md"

  if vim.fn.filereadable(full_path) == 1 then
    vim.notify("Error: A note with this name already exists.", vim.log.levels.ERROR)
    return
  end

  local all_tags = { para_type }
  if additional_tags ~= "" and additional_tags ~= nil then
    for tag in additional_tags:gmatch("([^:]+)") do
      table.insert(all_tags, tag)
    end
  end

  local today = os.date("%Y-%m-%d")
  local lines = {
    "---",
    "title: " .. title,
    "date: " .. today,
    "tags:",
  }

  for _, tag in ipairs(all_tags) do
    table.insert(lines, "  - " .. tag)
  end

  table.insert(lines, "---")
  table.insert(lines, "")
  table.insert(lines, "# " .. title)
  table.insert(lines, "")

  if vim.fn.writefile(lines, full_path) == 0 then
    vim.cmd("edit " .. vim.fn.fnameescape(full_path))
    vim.cmd("normal! G")
    vim.notify(para_type .. " note created with " .. #all_tags .. " tags.", vim.log.levels.INFO)
  else
    vim.notify("Error: Failed to create the note file.", vim.log.levels.ERROR)
  end
end

local function import_yesterday_completed_tasks()
  vim.defer_fn(function()
    local line_count = vim.fn.line("$")
    if line_count > 11 then
      return
    end

    local journal_root = vim.fn.expand(opts.dir .. "/" .. opts.daily_notes.folder)
    local yesterday_time = os.time() - 86400
    local yesterday_date = os.date(opts.daily_notes.date_format, yesterday_time)
    local yesterday_file = journal_root .. "/" .. yesterday_date .. ".md"

    if vim.fn.filereadable(yesterday_file) == 0 then
      return
    end
    local yesterday_content = vim.fn.readfile(yesterday_file)
    local completed_tasks = {}
    local in_done_section = false
    for _, line in ipairs(yesterday_content) do
      if line:match("^## Done") then
        in_done_section = true
      elseif in_done_section and line:match("^##") then
        break
      elseif in_done_section and line:match("^%- %[x%]") then
        table.insert(completed_tasks, line)
      end
    end
    if #completed_tasks == 0 then
      return
    end
    local current_buf_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local done_section_line_num = -1
    for i, line in ipairs(current_buf_lines) do
      if line:match("^## Done") then
        done_section_line_num = i
        break
      end
    end
    if done_section_line_num ~= -1 then
      table.insert(completed_tasks, 1, "### From " .. yesterday_date)
      table.insert(completed_tasks, 1, "")
      vim.api.nvim_buf_set_lines(0, done_section_line_num, done_section_line_num, false, completed_tasks)
    end
  end, 150)
end

local function CreateCheckbox()
  local line = vim.api.nvim_get_current_line()
  local indent, content = line:match("(^%s*)(.*)")

  if indent == nil then
    indent = ""
  end

  if content == nil then
    content = ""
  end

  if not line:match("^%s*%- %[.%]") then
    vim.api.nvim_set_current_line(indent .. "- [ ] " .. content)
  end
end

local function ToggleExistingCheckbox()
  local line = vim.api.nvim_get_current_line()
  local indent = line:match("(^%s*)")

  if indent == nil then
    indent = ""
  end

  if line:match("^%s*%- %[x%]") then
    vim.api.nvim_set_current_line(indent .. line:gsub("^%s*%- %[x%]", "- [ ]"))
  elseif line:match("^%s*%- %[ %]") then
    vim.api.nvim_set_current_line(indent .. line:gsub("^%s*%- %[ %]", "- [x]"))
  end
end

vim.api.nvim_create_user_command("ObsidianCreateCheckbox", CreateCheckbox, {})
vim.api.nvim_create_user_command("ObsidianToggleExistingCheckbox", ToggleExistingCheckbox, {})

vim.api.nvim_create_user_command("ObsidianSmartToday", function()
  vim.cmd("ObsidianToday")
  import_yesterday_completed_tasks()
end, {})

local map = vim.keymap.set
local leader = "<leader>"

map("n", leader .. "np", function()
  CreateParaNote("Project")
end, { desc = "Obsidian: New Project Note" })
map("n", leader .. "na", function()
  CreateParaNote("Area")
end, { desc = "Obsidian: New Area Note" })
map("n", leader .. "nr", function()
  CreateParaNote("Resource")
end, { desc = "Obsidian: New Resource Note" })
map("n", leader .. "nc", function()
  CreateParaNote("Archive")
end, { desc = "Obsidian: New Archive Note" })

map("n", leader .. "nj", "<cmd>ObsidianSmartToday<cr>", { desc = "Obsidian: Smart Today" })
map("v", leader .. "nl", "<cmd>ObsidianLinkNew<cr>", { desc = "Obsidian: Link New" })
map("n", leader .. "ncc", CreateCheckbox, { desc = "Obsidian: Create Checkbox" })
map("n", leader .. "x", ToggleExistingCheckbox, { desc = "Obsidian: Toggle Checkbox" })
map("n", leader .. "wo", "<cmd>ObsidianOpen<cr>", { desc = "Obsidian: Open Vault" })
map("n", leader .. "wf", "<cmd>ObsidianSearch<cr>", { desc = "Obsidian: Search notes" })
map("n", leader .. "wb", "<cmd>ObsidianBacklinks<cr>", { desc = "Obsidian: Show backlinks" })
map("n", leader .. "nte", "<cmd>ObsidianTemplate<cr>", { desc = "Obsidian: Show template" })
map("n", leader .. "gl", "<cmd>ObsidianFollowLink<cr>", { desc = "Obsidian: Follow link under cursor" })
