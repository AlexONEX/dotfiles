vim.g.wiki_root = "~/wiki"
vim.g.wiki_filetypes = { "md" }
vim.g.wiki_index_name = "index"
vim.g.wiki_link_creation = {
  md = {
    link_type = "md",
    url_extension = ".md",
    url_transform = function(x)
      return vim.fn["wiki#url#utils#url_encode_specific"](string.gsub(string.lower(x), "%s+", "-"), "()")
    end,
    link_text = function(url)
      return vim.fn["wiki#toc#get_page_title"](url)
    end,
  },
}
vim.g.wiki_tag_scan_num_lines = 25
vim.g.wiki_journal = {
  name = "journal",
  root = "~/wiki/journal/",
  frequency = "daily",
  date_format = {
    daily = "%Y-%m-%d",
    weekly = "%Y_w%V",
    monthly = "%Y_m%m",
  },
}

function Create_para_note(para_type)
  local wiki_root = vim.fn.expand(vim.g.wiki_root)
  if vim.fn.isdirectory(wiki_root) ~= 1 then
    vim.fn.mkdir(wiki_root, "p")
  end

  local title = vim.fn.input("Note title: ")
  if title == "" then
    print("Note creation cancelled")
    return
  end

  local additional_tags = vim.fn.input("Additional tags (Example - Programming:JavaScript): ")

  local tags = ":" .. para_type .. ":"
  if additional_tags ~= "" then
    tags = tags .. additional_tags .. ":"
  end

  local filename = string.gsub(string.lower(title), "%s+", "-")
  local full_path = wiki_root .. "/" .. filename .. ".md"

  local lines = {
    "---",
    "title: " .. title,
    "date: " .. os.date("%Y-%m-%d"),
    "---",
    "",
    tags,
    "",
    "# " .. title,
    "",
  }

  local result = vim.fn.writefile(lines, full_path)
  if result == 0 then
    vim.cmd("edit " .. vim.fn.fnameescape(full_path))
    vim.cmd("normal! G")
    print("Note created with tags: " .. tags)
  else
    print("Failed to create note file. Error code: " .. result)
    print("Wiki root: " .. wiki_root)
    print("Full path: " .. full_path)
  end
end

function Create_project_note()
  Create_para_note("Project")
end

function Create_area_note()
  Create_para_note("Area")
end

function Create_resource_note()
  Create_para_note("Resource")
end

function Create_archive_note()
  Create_para_note("Archive")
end

function Open_wiki_directory()
  local wiki_root = vim.fn.expand(vim.g.wiki_root)
  if vim.fn.isdirectory(wiki_root) ~= 1 then
    print("Wiki root directory does not exist: " .. wiki_root)
    return
  end
  vim.cmd("cd " .. vim.fn.fnameescape(wiki_root))
  vim.cmd("edit .")
end

function Open_journal_with_template()
  -- Primero, abrimos el diario actual con WikiJournal
  vim.cmd("WikiJournal")

  -- Esperamos a que se abra el archivo
  vim.defer_fn(function()
    -- Verificamos si el archivo está vacío (nuevo) comprobando si tiene contenido
    local line_count = vim.fn.line("$")
    local is_empty = line_count <= 1 and vim.fn.getline(1) == ""

    if is_empty then
      -- Obtenemos la fecha de hoy en formato YYYY-MM-DD
      local today = os.date("%Y-%m-%d")

      -- Creamos el template básico
      local template = {
        "# Journal: " .. today,
        "",
        "## Todo",
        "",
        "- [ ] ",
        "",
        "## Done",
        "",
      }

      vim.api.nvim_buf_set_lines(0, 0, -1, false, template)

      local journal_root = vim.fn.expand(vim.g.wiki_journal.root)
      local yesterday = os.date("%Y-%m-%d", os.time() - 86400) -- 86400 segundos = 1 día
      local yesterday_format = string.gsub(vim.g.wiki_journal.date_format.daily, "%%", "")
      yesterday_format = string.gsub(yesterday_format, "Y", os.date("%Y", os.time() - 86400))
      yesterday_format = string.gsub(yesterday_format, "m", os.date("%m", os.time() - 86400))
      yesterday_format = string.gsub(yesterday_format, "d", os.date("%d", os.time() - 86400))

      local yesterday_file = journal_root .. "/" .. yesterday_format .. ".md"

      if vim.fn.filereadable(yesterday_file) == 1 then
        local yesterday_content = vim.fn.readfile(yesterday_file)
        local done_tasks = {}
        local in_done_section = false

        for _, line in ipairs(yesterday_content) do
          if line:match("^## Done") then
            in_done_section = true
          elseif line:match("^##") and in_done_section then
            in_done_section = false
          elseif in_done_section and line:match("^%- %[x%]") then
            table.insert(done_tasks, line)
          end
        end

        if #done_tasks > 0 then
          local done_pos = 0
          local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
          for i, line in ipairs(lines) do
            if line:match("^## Done") then
              done_pos = i
              break
            end
          end

          if done_pos > 0 then
            table.insert(done_tasks, 1, "### From " .. yesterday)
            vim.api.nvim_buf_set_lines(0, done_pos, done_pos + 1, false, { lines[done_pos], "", done_tasks[1] })

            if #done_tasks > 1 then
              vim.api.nvim_buf_set_lines(0, done_pos + 3, done_pos + 3, false, vim.list_slice(done_tasks, 2))
            end
          end
        end
      end

      for i, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
        if line:match("^%- %[ %]") then
          vim.api.nvim_win_set_cursor(0, { i, 6 })
          vim.cmd("startinsert")
          break
        end
      end
    end
  end, 100)
end

function Toggle_task()
  local line_nr = vim.fn.line(".")
  local line = vim.api.nvim_buf_get_lines(0, line_nr - 1, line_nr, false)[1]

  if line:match("^%- %[.%]") then
    if line:match("^%- %[ %]") then
      line = line:gsub("^%- %[ %]", "- [x]")
    else
      line = line:gsub("^%- %[x%]", "- [ ]")
    end

    vim.api.nvim_buf_set_lines(0, line_nr - 1, line_nr, false, { line })
  end
end

vim.cmd("command! WikiJournalTemplate lua Open_journal_with_template()")
vim.cmd("command! WikiToggleTask lua Toggle_task()")

function Create_working_day_journal()
  local journal_root = vim.fn.expand(vim.g.wiki_journal.root)
  if vim.fn.isdirectory(journal_root) ~= 1 then
    vim.fn.mkdir(journal_root, "p")
  end

  local today = os.date("%Y-%m-%d")
  local filename = today .. ".md"
  local full_path = journal_root .. "/" .. filename
  -- Verificar si el archivo ya existe
  if vim.fn.filereadable(full_path) == 1 then
    vim.cmd("edit " .. vim.fn.fnameescape(full_path))
    print("Opened existing journal: " .. filename)
    return
  end

  local lines = {
    "---",
    "title: Working Day - " .. today,
    "date: " .. today,
    "---",
    "",
    ":journal:",
    "",
    "# Working Day - " .. today,
    "",
    "## Tasks",
    "",
    "## Notes",
    "",
    "## Reflections",
    "",
  }

  local result = vim.fn.writefile(lines, full_path)
  if result == 0 then
    vim.cmd("edit " .. vim.fn.fnameescape(full_path))
    vim.cmd("normal! G")
    print("Created working day journal: " .. filename)
  else
    print("Failed to create journal file. Error code: " .. result)
    print("Journal root: " .. journal_root)
    print("Full path: " .. full_path)
  end
end

vim.cmd("command! WikiCreateProject lua Create_project_note()")
vim.cmd("command! WikiCreateArea lua Create_area_note()")
vim.cmd("command! WikiCreateResource lua Create_resource_note()")
vim.cmd("command! WikiCreateArchive lua Create_archive_note()")
vim.cmd("command! WikiWorkingDay lua Create_working_day_journal()")

vim.api.nvim_set_keymap("n", "<leader>np", ":WikiCreateProject<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>na", ":WikiCreateArea<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>nr", ":WikiCreateResource<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>nc", ":WikiCreateArchive<CR>", { noremap = true, silent = true })

vim.api.nvim_set_keymap("n", "<leader>wt", ":WikiTagList<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>ws", ":WikiTagSearch<CR>", { noremap = true, silent = true })

vim.api.nvim_set_keymap("n", "<leader>wo", ":lua Open_wiki_directory()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>nj", ":WikiJournalTemplate<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>x", ":WikiToggleTask<CR>", { noremap = true, silent = true })
