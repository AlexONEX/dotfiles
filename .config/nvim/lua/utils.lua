local fn = vim.fn
local version = vim.version
local M = {}

function M.executable(name)
  if fn.executable(name) > 0 then
    return true
  end
  return false
end

--- check whether a feature exists in Nvim
--- @param feat string the feature name, like `nvim-0.7` or `unix`.
--- @return boolean
function M.has(feat)
  if fn.has(feat) == 1 then
    return true
  end
  return false
end

--- Create a dir if it does not exist
function M.may_create_dir(dir)
  local res = fn.isdirectory(dir)
  if res == 0 then
    fn.mkdir(dir, "p")
  end
end

--- Generate random integers in the range [Low, High], inclusive,
--- adapted from https://stackoverflow.com/a/12739441/6064933
--- @param low integer the lower value for this range
--- @param high integer the higher value for this range
--- @return integer
function M.rand_int(low, high)
  -- Use lua to generate random int, see also: https://stackoverflow.com/a/20157671/6064933
  math.randomseed(os.time())
  return math.random(low, high)
end

--- Select a random element from a sequence/list.
--- @param seq any[] the sequence to choose an element
function M.rand_element(seq)
  local idx = M.rand_int(1, #seq)
  return seq[idx]
end

--- check if the current nvim version is compatible with the allowed version
--- @param expected_version string
--- @return boolean
function M.is_compatible_version(expected_version)
  -- check if we have the latest stable version of nvim
  local expect_ver = version.parse(expected_version)
  local actual_ver = vim.version()
  if expect_ver == nil then
    local msg = string.format("Unsupported version string: %s", expected_version)
    vim.api.nvim_err_writeln(msg)
    return false
  end
  local result = version.cmp(expect_ver, actual_ver)
  if result ~= 0 then
    local ver = string.format("%s.%s.%s", actual_ver.major, actual_ver.minor, actual_ver.patch)
    local msg = string.format(
      "Expect nvim version %s, but your current nvim version is %s. Use at your own risk!",
      expected_version,
      ver
    )
    vim.api.nvim_err_writeln(msg)
  end
  return true
end

-- Treesitter utils
local has_treesitter, ts = pcall(require, "vim.treesitter")
local _, query = pcall(require, "vim.treesitter.query")

local MATH_NODES = {
  displayed_equation = true,
  inline_formula = true,
  math_environment = true,
}

local function get_node_at_cursor()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local cursor_range = { cursor[1] - 1, cursor[2] }
  local buf = vim.api.nvim_get_current_buf()
  local ok, parser = pcall(ts.get_parser, buf, "latex")
  if not ok or not parser then
    return
  end
  local root_tree = parser:parse()[1]
  local root = root_tree and root_tree:root()
  if not root then
    return
  end
  return root:named_descendant_for_range(cursor_range[1], cursor_range[2], cursor_range[1], cursor_range[2])
end

function M.in_comment()
  if has_treesitter then
    local node = get_node_at_cursor()
    while node do
      if node:type() == "comment" then
        return true
      end
      node = node:parent()
    end
    return false
  end
end

function M.in_mathzone()
  if has_treesitter then
    local node = get_node_at_cursor()
    while node do
      -- Debug: imprime el tipo de nodo
      print("Node type:", node:type())
      if MATH_NODES[node:type()] then
        return true
      end
      node = node:parent()
    end
    return false
  end
  return false
end

return M
