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
  local result = vim.system({ python_exe, "--version" }, { text = true }):wait()
  local major, minor = result.stdout:match("Python (%d+)%.(%d+)")
  local py_version = major and minor and ("py" .. major .. minor) or "py310"

  return {
    exe = python_exe,
    version = py_version,
    venv = venv,
  }
end

return M
