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
  },
  completion = {
    nvim_cmp = true,
    min_chars = 2,
  },
  ui = {
    enable = false,
  },
}

require("obsidian").setup(opts)

local function GenerateFrontmatter(data)
  local lines = { "---" }
  data.date = data.date or os.date("%Y-%m-%d")

  table.insert(lines, "title: " .. (data.title or "Untitled"))
  table.insert(lines, "date: " .. data.date)

  if data.tags and #data.tags > 0 then
    table.insert(lines, "tags:")
    for _, tag in ipairs(data.tags) do
      table.insert(lines, "  - " .. tag)
    end
  end

  table.insert(lines, "---")
  return lines
end

local function NoteCreator(args)
  if vim.fn.filereadable(args.path) == 1 then
    if args.open_existing then
      vim.cmd("edit " .. vim.fn.fnameescape(args.path))
      vim.notify("Opening existing note: " .. vim.fn.fnamemodify(args.path, ":t"), vim.log.levels.INFO)
      return
    else
      vim.notify("Error: A note with this name already exists.", vim.log.levels.ERROR)
      return
    end
  end

  local dir = vim.fn.fnamemodify(args.path, ":h")
  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, "p")
  end

  if vim.fn.writefile(args.content, args.path) == 0 then
    vim.cmd("edit " .. vim.fn.fnameescape(args.path))
    vim.cmd("normal! G")
    vim.notify("Note created: " .. vim.fn.fnamemodify(args.path, ":t"), vim.log.levels.INFO)
  else
    vim.notify("Error: Failed to create the note file.", vim.log.levels.ERROR)
  end
end

local function CreateParaNote(para_type)
  local title = vim.fn.input(para_type .. " Title: ")
  if title == "" or title == nil then
    return vim.notify("Note creation canceled.", vim.log.levels.WARN)
  end

  local additional_tags_str = vim.fn.input("Additional tags (e.g., Hobbies:Gaming): ")
  local all_tags = { para_type }
  if additional_tags_str ~= "" then
    for tag in additional_tags_str:gmatch("([^:]+)") do
      table.insert(all_tags, tag)
    end
  end

  local filename = title:gsub("%s+", "-"):gsub("[^A-Za-z0-9-]", ""):lower() .. ".md"
  local full_path = vim.fn.expand(opts.dir) .. "/" .. filename

  local content = GenerateFrontmatter { title = title, tags = all_tags }
  table.insert(content, "")
  table.insert(content, "# " .. title)

  NoteCreator { path = full_path, content = content, open_existing = false }
end

local function CreateJournalNote()
  local today_date = os.date("%Y-%m-%d")
  local file_title = "Journal - " .. today_date
  local filename = "Journal-" .. today_date .. ".md"
  local full_path = vim.fn.expand(opts.dir .. "/" .. opts.daily_notes.folder) .. "/" .. filename

  local content = GenerateFrontmatter { title = file_title, date = today_date, tags = { "journal" } }
  table.insert(content, "")
  table.insert(content, "# " .. file_title)

  NoteCreator { path = full_path, content = content, open_existing = true }
end

local function CreateDailyNote()
  local today_date = os.date(opts.daily_notes.date_format)
  local filename = today_date .. ".md"
  local full_path = vim.fn.expand(opts.dir .. "/" .. opts.daily_notes.folder) .. "/" .. filename

  local content = GenerateFrontmatter { title = today_date, tags = { "daily" } }
  table.insert(content, "")
  table.insert(content, "# " .. today_date)
  table.insert(content, "")
  table.insert(content, "## To-Do")
  table.insert(content, "- [ ] ")
  table.insert(content, "")
  table.insert(content, "## Done")
  table.insert(content, "")

  NoteCreator { path = full_path, content = content, open_existing = true }
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
  CreateDailyNote()
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

map("n", leader .. "nj", "<cmd>ObsidianSmartToday<cr>", { desc = "Obsidian: Smart Today (no templates)" })
map("n", leader .. "njj", CreateJournalNote, { desc = "Obsidian: New Journal Note" })

map("v", leader .. "nl", "<cmd>ObsidianLinkNew<cr>", { desc = "Obsidian: Link New" })
map("n", leader .. "ncc", CreateCheckbox, { desc = "Obsidian: Create Checkbox" })
map("n", leader .. "x", ToggleExistingCheckbox, { desc = "Obsidian: Toggle Checkbox" })
map("n", leader .. "wo", "<cmd>ObsidianOpen<cr>", { desc = "Obsidian: Open Vault" })
map("n", leader .. "wf", "<cmd>ObsidianSearch<cr>", { desc = "Obsidian: Search notes" })
map("n", leader .. "wb", "<cmd>ObsidianBacklinks<cr>", { desc = "Obsidian: Show backlinks" })
map("n", leader .. "nte", "<cmd>ObsidianTemplate<cr>", { desc = "Obsidian: Show template" })
map("n", leader .. "gl", "<cmd>ObsidianFollowLink<cr>", { desc = "Obsidian: Follow link under cursor" })
