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

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt.conceallevel = 2
  end,
  desc = "Set conceal level for markdown files",
})

local function CreateParaNote(para_type)
  local vault_path = vim.fn.expand(opts.dir)

  local title = vim.fn.input(para_type .. " Title: ")
  if title == "" or title == nil then
    vim.notify("Creación de nota cancelada.", vim.log.levels.WARN)
    return
  end

  local additional_tags = vim.fn.input("Tags adicionales (ej: Programming:JavaScript): ")

  local tags = ":" .. para_type .. ":"
  if additional_tags ~= "" then
    tags = tags .. additional_tags .. ":"
  end

  local filename = title:gsub("%s+", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
  local full_path = vault_path .. "/" .. filename .. ".md"

  if vim.fn.filereadable(full_path) == 1 then
    vim.notify("Error: Ya existe una nota con este nombre.", vim.log.levels.ERROR)
    return
  end

  local today = os.date("%Y-%m-%d")
  local lines = {
    "---",
    "title: " .. title,
    "date: " .. today,
    "---",
    "",
    tags,
    "",
    "# " .. title,
    "",
  }

  if vim.fn.writefile(lines, full_path) == 0 then
    vim.cmd("edit " .. vim.fn.fnameescape(full_path))
    vim.cmd("normal! G")
    vim.notify(para_type .. " nota creada con tags: " .. tags, vim.log.levels.INFO)
  else
    vim.notify("Error: Fallo al crear el archivo de la nota.", vim.log.levels.ERROR)
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

<<<<<<< Updated upstream
vim.api.nvim_create_user_command("ObsidianToggleCheckbox", function()
  local line = vim.api.nvim_get_current_line()
  if line:match("^%s*%- %[x%]") then
    vim.api.nvim_set_current_line(line:gsub("^%s*%- %[x%]", "- [ ]"))
  elseif line:match("^%s*%- %[ %]") then
    vim.api.nvim_set_current_line(line:gsub("^%s*%- %[ %]", "- [x]"))
  else
    vim.api.nvim_set_current_line("- [ ] " .. line)
  end
end, {})

||||||| Stash base
=======
local function CreateMarkdownLink()
  local display_text = vim.fn.input("Title of the link: ")
  if display_text == "" or display_text == nil then
    vim.notify("Creation canceled", vim.log.levels.WARN)
    return
  end

  local link_target = vim.fn.input("Target (URL or Archivo): ")
  if link_target == "" or link_target == nil then
    vim.notify("Creation canceled.", vim.log.levels.WARN)
    return
  end

  -- Construye el string del enlace en formato Markdown.
  local markdown_link = string.format("[%s](%s)", display_text, link_target)

  -- Inserta el enlace en la posición actual del cursor.
  vim.api.nvim_put({ markdown_link }, "c", false, true)
end

>>>>>>> Stashed changes
vim.api.nvim_create_user_command("ObsidianSmartToday", function()
  vim.cmd("ObsidianToday")
  import_yesterday_completed_tasks()
end, {})

local map = vim.keymap.set
local leader = "<leader>"

map("n", leader .. "np", function()
  CreateParaNote("Project")
end, { desc = "Obsidian: Nueva Nota de Proyecto" })
map("n", leader .. "na", function()
  CreateParaNote("Area")
end, { desc = "Obsidian: Nueva Nota de Área" })
map("n", leader .. "nr", function()
  CreateParaNote("Resource")
end, { desc = "Obsidian: Nueva Nota de Recurso" })
map("n", leader .. "nc", function()
  CreateParaNote("Archive")
end, { desc = "Obsidian: Nueva Nota de Archivo" })

map("n", leader .. "nj", "<cmd>ObsidianSmartToday<cr>", { desc = "Obsidian: Open Today's Note (Smart)" })
map("n", leader .. "nl", "<cmd>ObsidianLinkNew<cr>", { desc = "Obsidian: New Link" })
map("n", leader .. "nt", "<cmd>ObsidianToggleCheckbox<cr>", { desc = "Obsidian: Create/Toggle Checkbox" })
map("n", leader .. "wo", "<cmd>ObsidianOpen<cr>", { desc = "Obsidian: Open Vault in File Manager" })
map("n", leader .. "wf", "<cmd>ObsidianSearch<cr>", { desc = "Obsidian: Search Notes" })
map("n", leader .. "wb", "<cmd>ObsidianBacklinks<cr>", { desc = "Obsidian: Show Backlinks" })
map("n", leader .. "nte", "<cmd>ObsidianTemplate<cr>", { desc = "Obsidian: Insert Template" })
map("n", leader .. "gl", "<cmd>ObsidianFollowLink<cr>", { desc = "Obsidian: Follow link under cursor" })
map("n", leader .. "nL", "<cmd>CreateMarkdownLink", { desc = "Obsidian: Nuevo Enlace Genérico (URL/Archivo)" })
map("n", leader .. "nj", "<cmd>ObsidianSmartToday<cr>", { desc = "Obsidian: Abrir Nota de Hoy (Inteligente)" })
map("v", leader .. "nl", "<cmd>ObsidianLinkNew<cr>", { desc = "Obsidian: Nuevo Enlace a Nota" })
map("n", leader .. "x", "<cmd>ObsidianToggleCheckbox<cr>", { desc = "Obsidian: Alternar Checkbox" })
map("n", leader .. "wo", "<cmd>ObsidianOpen<cr>", { desc = "Obsidian: Abrir Bóveda en Explorador de Archivos" })
map("n", leader .. "wf", "<cmd>ObsidianSearch<cr>", { desc = "Obsidian: Buscar Notas" })
map("n", leader .. "wb", "<cmd>ObsidianBacklinks<cr>", { desc = "Obsidian: Mostrar Backlinks" })
map("n", leader .. "nte", "<cmd>ObsidianTemplate<cr>", { desc = "Obsidian: Insertar Plantilla" })
map("n", leader .. "gl", "<cmd>ObsidianFollowLink<cr>", { desc = "Obsidian: Seguir enlace bajo el cursor" })
