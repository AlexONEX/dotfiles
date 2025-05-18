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

  -- Construir las tags según el formato de wiki.vim (:tag:)
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

-- Funciones específicas para cada tipo PARA
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

  -- Opción 1: Cambia el directorio de trabajo Y abre netrw
  vim.cmd("cd " .. vim.fn.fnameescape(wiki_root))
  vim.cmd("edit .")
end

-- Comandos para cada tipo
vim.cmd("command! WikiCreateProject lua Create_project_note()")
vim.cmd("command! WikiCreateArea lua Create_area_note()")
vim.cmd("command! WikiCreateResource lua Create_resource_note()")
vim.cmd("command! WikiCreateArchive lua Create_archive_note()")

-- Keymaps para el sistema PARA
vim.api.nvim_set_keymap("n", "<leader>np", ":WikiCreateProject<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>na", ":WikiCreateArea<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>nr", ":WikiCreateResource<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>nc", ":WikiCreateArchive<CR>", { noremap = true, silent = true })

-- Keymaps adicionales para navegación
vim.api.nvim_set_keymap("n", "<leader>wt", ":WikiTagList<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>ws", ":WikiTagSearch<CR>", { noremap = true, silent = true })

-- Keymap to open the wiki directory
vim.api.nvim_set_keymap("n", "<leader>wo", ":lua Open_wiki_directory()<CR>", { noremap = true, silent = true })
