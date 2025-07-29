vim.opt_local.concealcursor = "c"
vim.opt_local.conceallevel = 2
vim.opt_local.synmaxcol = 3000
vim.opt_local.wrap = true
vim.opt_local.formatoptions:remove { "o", "r" }

local M = {}

--- Adds a list symbol (+ ) to the beginning of lines.
--- @param start_line number The starting line number (1-indexed).
--- @param end_line number The ending line number (1-indexed).
function M.add_list_symbol(start_line, end_line)
  for line = start_line, end_line do
    local text = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1]
    local indent = text:match("^%s*") or "" -- Handle cases with no leading spaces
    local new_text = indent .. "+ " .. text:sub(#indent + 1)
    vim.api.nvim_buf_set_lines(0, line - 1, line, false, { new_text })
  end
end

--- Adds a backslash (\) for explicit line breaks at the end of lines.
--- @param start_line number The starting line number (1-indexed).
--- @param end_line number The ending line number (1-indexed).
function M.add_line_break(start_line, end_line)
  for line = start_line, end_line do
    local text = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1]
    vim.api.nvim_buf_set_lines(0, line - 1, line, false, { text .. "\\" })
  end
end

--- Formats the current buffer using LSP and then saves the file.
function M.format_and_save()
  vim.lsp.buf.format()
  vim.cmd("write")
end

--- Inserts a Markdown fenced code block (```) and places the cursor inside.
function M.insert_code_block()
  vim.api.nvim_put({ "```", "", "```" }, "l", true, true)
  -- Move cursor to the empty line inside the code block
  vim.api.nvim_win_set_cursor(0, { vim.api.nvim_win_get_cursor(0)[1] + 1, 0 })
  vim.cmd("startinsert!") -- Enter insert mode
end

--- Adds a Markdown reference definition to the end of the buffer.
--- If a "References" section doesn't exist, it will be added.
--- @param label string The label for the reference link.
--- @param url string The URL for the reference.
--- @param title string|nil An optional title for the reference.
function M.add_reference_at_end(label, url, title)
  vim.schedule(function()
    local bufnr = vim.api.nvim_get_current_buf()
    local line_count = vim.api.nvim_buf_line_count(bufnr)

    -- Prepare reference definition
    local ref_def = "[" .. label .. "]: " .. url
    if title and title ~= "" then
      ref_def = ref_def .. ' "' .. title .. '"'
    end

    -- Check if references section exists (case-insensitive)
    local buffer_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

    local has_ref_section = false
    for _, line in ipairs(buffer_lines) do
      if line:match("^%s*<!%-%-.*[Rr]eferences.*%-%->[%s]*$") then
        has_ref_section = true
        break
      end
    end

    local lines_to_add = {}
    -- Add references header if it doesn't exist
    if not has_ref_section then
      if line_count > 0 and buffer_lines[line_count] ~= "" then
        table.insert(lines_to_add, "") -- Add a blank line before the header if buffer isn't empty and last line isn't blank
      end
      table.insert(lines_to_add, "")
    else
      -- If references section exists, ensure there's a blank line before the new ref if the last line isn't blank
      if line_count > 0 and buffer_lines[line_count] ~= "" then
        table.insert(lines_to_add, "")
      end
    end

    table.insert(lines_to_add, ref_def)

    -- Insert at buffer end
    vim.api.nvim_buf_set_lines(bufnr, line_count, line_count, false, lines_to_add)
  end)
end

--- Retrieves all unique reference link labels from the current buffer.
--- @return table A list of unique reference labels.
function M.get_ref_link_labels()
  local labels = {}
  local seen = {} -- To avoid duplicates
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  for _, line in ipairs(lines) do
    -- Pattern explanation:
    -- %[.-%] matches [link text] (non-greedy)
    -- %[(.-)%] matches [label] and captures the label content
    local start_pos = 1
    while start_pos <= #line do
      -- Find reference definitions like [label]: url or [link text][label]
      local match_start, match_end, label_def = string.find(line, "^%s*%[(.-)%]:", start_pos)
      if match_start then
        if label_def and label_def ~= "" and not seen[label_def] then
          table.insert(labels, label_def)
          seen[label_def] = true
        end
        start_pos = match_end + 1
      else
        -- Find reference links like [link text][label]
        match_start, match_end, label_link = string.find(line, "%[.-%]%[(.-)%]", start_pos)
        if match_start then
          if label_link and label_link ~= "" and not seen[label_link] then
            table.insert(labels, label_link)
            seen[label_link] = true
          end
          start_pos = match_end + 1
        else
          break
        end
      end
    end
  end

  table.sort(labels) -- Sort labels alphabetically for better completion experience
  return labels
end

--- Helper function to count consecutive spaces at the beginning of a string.
--- This is primarily used for the `complete` function of the user command.
--- @param str string The string to check.
--- @return number The count of consecutive spaces.
local function count_consecutive_spaces(str)
  local count = 0
  for i = 1, #str do
    if str:sub(i, i) == " " then
      count = count + 1
    else
      break
    end
  end
  return count
end

--- Sets up Neovim keymaps for Markdown functionalities.
local function setup_keymaps()
  local opts = { buffer = true, silent = true }

  -- Keymap for adding list symbols
  vim.keymap.set("n", "+", ":set operatorfunc=v:lua.Ftplugin_Markdown.add_list_symbol<CR>g@", opts)
  vim.keymap.set(
    "x",
    "+",
    ':<C-U>lua Ftplugin_Markdown.add_list_symbol(vim.fn.line("\'<"), vim.fn.line("\'>"))<CR>',
    opts
  )

  -- Keymap for adding line breaks (backslash)
  vim.keymap.set("n", "\\", ":set operatorfunc=v:lua.Ftplugin_Markdown.add_line_break<CR>g@", opts)
  vim.keymap.set(
    "x",
    "\\",
    ':<C-U>lua Ftplugin_Markdown.add_line_break(vim.fn.line("\'<"), vim.fn.line("\'>"))<CR>',
    opts
  )

  -- Keymap for format and save
  vim.keymap.set("n", "<C-s>", function()
    M.format_and_save()
  end, opts)

  -- Keymap for inserting code block
  vim.keymap.set("n", "<space>mc", function()
    M.insert_code_block()
  end, opts)

  -- Keymaps for markdownfootnotes.nvim (if available)
  -- Assumes 'markdownfootnotes.nvim' is installed and loaded
  if vim.fn.exists(":FootnoteNumber") == 1 then
    vim.keymap.set("n", "^^", ":<C-U>call markdownfootnotes#VimFootnotes('i')<CR>", opts)
    vim.keymap.set("i", "^^", "<C-O>:<C-U>call markdownfootnotes#VimFootnotes('i')<CR>", opts)
    vim.keymap.set("i", "@@", "<Plug>ReturnFromFootnote", { buffer = true })
    vim.keymap.set("n", "@@", "<Plug>ReturnFromFootnote", { buffer = true })
  end

  if pcall(require, "text_obj") then -- Safely check if text_obj module can be loaded
    vim.keymap.set("x", "ic", ":<C-U>lua require('text_obj').MdCodeBlock('i')<CR>", opts)
    vim.keymap.set("x", "ac", ":<C-U>lua require('text_obj').MdCodeBlock('a')<CR>", opts)
    vim.keymap.set("o", "ic", ":<C-U>lua require('text_obj').MdCodeBlock('i')<CR>", opts)
    vim.keymap.set("o", "ac", ":<C-U>lua require('text_obj').MdCodeBlock('a')<CR>", opts)
  end
end

function M.setup()
  setup_keymaps()

  -- Define the :AddRef user command
  vim.api.nvim_buf_create_user_command(0, "AddRef", function(opts)
    local args = vim.split(opts.args, " ", { trimempty = true })

    if #args < 2 then
      vim.print("Usage: :AddRef <label> <url> [title]")
      return
    end

    local label = args[1]
    local url = args[2]
    local title = args[3] -- Optional title

    M.add_reference_at_end(label, url, title)
  end, {
    desc = "Add reference link at buffer end",
    nargs = "+", -- Allows one or more arguments
    complete = function(arg_lead, cmdline, curpos)
      -- Check if we are completing the first argument (label) or subsequent arguments
      local num_spaces = count_consecutive_spaces(cmdline)
      if num_spaces == 0 and cmdline:sub(1, 1) ~= " " then -- First argument, no leading spaces in cmdline yet
        return M.get_ref_link_labels()
      elseif num_spaces == 1 and cmdline:sub(curpos, curpos) == " " then -- First space after label, starting URL
        return {} -- No completion for URL
      elseif num_spaces >= 2 then -- After URL, starting title
        return {} -- No completion for title
      end
      -- Fallback for unexpected cases or if trying to complete the first argument after initial spaces
      if cmdline:match("^[^%s]+%s*$") and arg_lead == "" then -- Only one argument so far, and cursor is at the end
        return M.get_ref_link_labels()
      end
      return {}
    end,
  })
end

_G.Ftplugin_Markdown = M

M.setup()
