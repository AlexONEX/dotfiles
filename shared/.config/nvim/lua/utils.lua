local version = vim.version
local M = {}

--- check if the current nvim version is compatible with the allowed version
--- @param expected_version string
--- @return boolean
function M.is_compatible_version(expected_version)
  -- check if we have the latest stable version of nvim
  local expect_ver = version.parse(expected_version)
  local actual_ver = vim.version()
  if expect_ver == nil then
    local msg = string.format("Unsupported version string: %s", expected_version)
    vim.notify(msg, vim.log.levels.ERROR)
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
    vim.notify(msg, vim.log.levels.WARN)
  end
  return true
end

--- check if we are inside a git repo
--- @return boolean
function M.inside_git_repo()
  local result = vim.system({ "git", "rev-parse", "--is-inside-work-tree" }, { text = true }):wait()
  if result.code ~= 0 then
    return false
  end

  -- Manually trigger a special user autocmd InGitRepo (used lazyloading.
  vim.cmd([[doautocmd User InGitRepo]])

  return true
end

local function open_url(url)
  local r
  if vim.fn.has("mac") == 1 then
    r = vim.system({ "open", url }, { text = true }):wait()
  elseif vim.fn.has("unix") == 1 then
    local cmd = vim.fn.executable("xdg-open") == 1 and "xdg-open" or "firefox"
    r = vim.system({ cmd, url }, { text = true }):wait()
  elseif vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
    r = vim.system({ "cmd.exe", "/c", "start", "", url }, { text = true }):wait()
  else
    vim.notify("No command found to open URL (e.g., open, xdg-open, start)", vim.log.levels.ERROR)
    return false
  end
  if r.code == 0 then
    vim.notify("Opening: " .. url, vim.log.levels.INFO)
    return true
  end
  return false
end

function M.open_url_under_cursor()
  local line = vim.api.nvim_get_current_line()

  local md_url = line:match("%[.-%]%((https?://[%w%-%._~:/?#%[%]@!$&'()*+,;=]+)%)")
  if md_url then
    return open_url(md_url)
  end

  local plain_url = line:match("(https?://[%w%-%._~:/?#%[%]@!$&'()*+,;=]+)")
  if plain_url then
    return open_url(plain_url)
  end

  vim.notify("No URL found in the current line", vim.log.levels.WARN)
  return false
end

return M
