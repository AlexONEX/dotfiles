vim.bo.commentstring = "// %s"
vim.opt_local.formatoptions:remove { "o", "r" }

local M = {}

-- Enhanced terminal buffer creation with better positioning
local function create_term_buf(type, size)
  vim.opt.splitbelow = true
  vim.opt.splitright = true

  if type == "v" then
    vim.cmd("vnew")
  else
    vim.cmd("new")
  end

  -- Set buffer-local options
  vim.bo.buflisted = false
  vim.bo.bufhidden = "wipe"

  vim.cmd("resize " .. size)
end

-- Improved TypeScript file runner with error handling
function M.run_typescript()
  local src_path = vim.fn.expand("%:p:~")

  if vim.fn.executable("ts-node") ~= 1 then
    vim.notify(
      "ts-node not found! Please install with: npm install -g ts-node",
      vim.log.levels.ERROR,
      { title = "TypeScript Runner" }
    )
    return
  end

  -- Check if file exists
  if vim.fn.filereadable(src_path) ~= 1 then
    vim.notify("Current buffer has not been saved!", vim.log.levels.ERROR, { title = "TypeScript Runner" })
    return
  end

  create_term_buf("h", 20)
  local cmd = string.format("term ts-node %s", src_path)
  vim.cmd(cmd)
  vim.cmd("startinsert")
end

-- Enhanced backend runner with package.json validation
function M.run_backend()
  if vim.fn.filereadable("package.json") ~= 1 then
    vim.notify("No package.json found in the current directory!", vim.log.levels.ERROR, { title = "Backend Runner" })
    return
  end

  -- Check if dev script exists in package.json
  local package_json = vim.fn.json_decode(vim.fn.readfile("package.json"))
  if not package_json.scripts or not package_json.scripts.dev then
    vim.notify("No 'dev' script found in package.json!", vim.log.levels.ERROR, { title = "Backend Runner" })
    return
  end

  create_term_buf("h", 20)
  local cmd = "term npm run dev"
  vim.cmd(cmd)
  vim.cmd("startinsert")
end

_G.TypeScriptUtils = M

-- Key mappings with better descriptions
vim.api.nvim_buf_set_keymap(
  0,
  "n",
  "<F5>",
  ":lua TypeScriptUtils.run_typescript()<CR>",
  { noremap = true, silent = true, desc = "Run TypeScript file" }
)

vim.api.nvim_buf_set_keymap(
  0,
  "n",
  "<F6>",
  ":lua TypeScriptUtils.run_backend()<CR>",
  { noremap = true, silent = true, desc = "Run backend server" }
)
