local M = {}

function M.get_python_info()
  local venv = os.getenv("VIRTUAL_ENV")
  local python_exe = "python"

  if venv then
    if vim.fn.has("win32") == 1 then
      python_exe = venv .. "\\Scripts\\python.exe"
    else
      python_exe = venv .. "/bin/python"
    end
  end

  -- Detect Python version
  local version_cmd = python_exe .. " --version"
  local handle = io.popen(version_cmd .. " 2>&1")
  local result = handle:read("*a")
  handle:close()

  -- Parse the Python version (format: "Python 3.x.y")
  local major, minor = result:match("Python (%d+)%.(%d+)")
  local py_version = major and minor and ("py" .. major .. minor) or "py310" -- Default to 3.10 if detection fails

  return {
    exe = python_exe,
    version = py_version,
    venv = venv,
  }
end

return M
