-- Native statusline (replaces lualine). Full parity with the old lualine setup.
-- Cheap components run inline on every redraw; whole-buffer scans (trailing
-- space / mixed indent) are precomputed into buffer vars via a debounced
-- autocmd so redraws stay O(1).

local fn = vim.fn
local api = vim.api

-- Highlights: reuse existing groups, derive a couple from the active theme.
local function link_hl()
  local pmenu = api.nvim_get_hl(0, { name = "PmenuSel", link = false })
  local dir = api.nvim_get_hl(0, { name = "Directory", link = false })
  api.nvim_set_hl(0, "StlMode", { fg = pmenu.fg, bg = pmenu.bg, bold = true })
  api.nvim_set_hl(0, "StlBranch", { fg = dir.fg, italic = true, bold = true })
end
link_hl()

local modes = {
  n = "NORMAL",
  i = "INSERT",
  v = "VISUAL",
  V = "V-LINE",
  ["\22"] = "V-BLOCK",
  c = "COMMAND",
  t = "TERMINAL",
  R = "REPLACE",
  s = "SELECT",
  S = "S-LINE",
  ["\19"] = "S-BLOCK",
}

-- git diff counts, sourced from gitsigns (same origin lualine used).
local function git_diff()
  local d = vim.b.gitsigns_status_dict
  if not d then
    return ""
  end
  local parts = {}
  if (d.added or 0) > 0 then
    parts[#parts + 1] = "%#GitSignsAdd#+" .. d.added .. "%*"
  end
  if (d.changed or 0) > 0 then
    parts[#parts + 1] = "%#GitSignsChange#~" .. d.changed .. "%*"
  end
  if (d.removed or 0) > 0 then
    parts[#parts + 1] = "%#GitSignsDelete#-" .. d.removed .. "%*"
  end
  return table.concat(parts, " ")
end

local function branch()
  local d = vim.b.gitsigns_status_dict
  local head = d and d.head or ""
  if head == "" then
    return ""
  end
  return "%#StlBranch# " .. head:sub(1, 20) .. "%* "
end

local function diagnostics()
  local counts = vim.diagnostic.count(0)
  local labels = { "E:", "W:", "I:", "H:" }
  local hls = { "DiagnosticError", "DiagnosticWarn", "DiagnosticInfo", "DiagnosticHint" }
  local out = ""
  for i = 1, 4 do
    if counts[i] and counts[i] > 0 then
      out = out .. "%#" .. hls[i] .. "#" .. labels[i] .. counts[i] .. "%* "
    end
  end
  return out
end

-- names of LSP clients attached to this buffer (copilot excluded), or "no-lsp".
local function lsp_name()
  local names = {}
  for _, client in ipairs(vim.lsp.get_clients { bufnr = 0 }) do
    if client.name ~= "copilot" and client.name ~= "GitHub Copilot" then
      names[#names + 1] = client.name
    end
  end
  return #names > 0 and table.concat(names, ",") or "no-lsp"
end

local function virtual_env()
  if vim.bo.filetype ~= "python" then
    return ""
  end
  local conda_env = os.getenv("CONDA_DEFAULT_ENV")
  local venv_path = os.getenv("VIRTUAL_ENV")
  if venv_path == nil then
    if conda_env == nil then
      return ""
    end
    return string.format(" %s (conda) ", conda_env)
  end
  return string.format(" %s (venv) ", fn.fnamemodify(venv_path, ":t"))
end

local function spell()
  return vim.o.spell and "%#WarningMsg#[SPELL]%* " or ""
end

-- Chinese IME indicator (macOS + vim-xkbswitch), mirrors the old lualine one.
local function ime_state()
  if not vim.g.is_mac or not vim.g.XkbSwitchLib then
    return ""
  end
  local layout = fn.libcall(vim.g.XkbSwitchLib, "Xkb_Switch_getXkbLayout", "")
  if fn.match(layout, [[\v(Squirrel\.Rime|SCIM.ITABC)]]) ~= -1 then
    return "%#WarningMsg#[CN]%* "
  end
  return ""
end

-- Whole-buffer scans: precomputed into vim.b, read cheaply below.
local function scan_warnings(buf)
  if not vim.bo[buf].modifiable then
    vim.b[buf].stl_trailing, vim.b[buf].stl_mixed = "", ""
    return
  end
  local trailing = ""
  for i = 1, fn.line("$") do
    if fn.match(fn.getline(i), [[\v\s+$]]) ~= -1 then
      trailing = "[" .. i .. "]trailing"
      break
    end
  end
  local space_pat, tab_pat = [[\v^ +]], [[\v^\t+]]
  local si, ti = fn.search(space_pat, "nwc"), fn.search(tab_pat, "nwc")
  local same = fn.search([[\v^(\t+ | +\t)]], "nwc")
  local mixed = ""
  if same > 0 then
    mixed = "MI:" .. same
  elseif si > 0 and ti > 0 then
    mixed = "MI:" .. (si > ti and ti or si)
  end
  vim.b[buf].stl_trailing, vim.b[buf].stl_mixed = trailing, mixed
end

local function warn(txt)
  return txt ~= "" and ("%#WarningMsg#" .. txt .. "%* ") or ""
end

-- selene: allow(global_usage)
-- global required by the `%!v:lua.native_statusline()` statusline expression
function _G.native_statusline()
  local mode = modes[fn.mode()] or fn.mode():upper()
  local readonly = vim.bo.readonly and "[RO]" or ""
  local ff = ({ unix = "unix", dos = "win", mac = "mac" })[vim.bo.fileformat] or vim.bo.fileformat
  local enc = vim.bo.fileencoding ~= "" and vim.bo.fileencoding:upper() or ""

  local left = table.concat {
    "%#StlMode# " .. mode .. " %* ",
    "%f" .. readonly .. " ",
    branch(),
    git_diff(),
    virtual_env(),
    " %S ",
    spell(),
  }
  local right = table.concat {
    lsp_name() .. " ",
    diagnostics(),
    warn(vim.b.stl_trailing or ""),
    warn(vim.b.stl_mixed or ""),
    enc .. " " .. ff .. " " .. vim.bo.filetype .. " ",
    ime_state(),
    "%l:%c %p%% ",
  }
  return left .. "%=" .. right
end

vim.o.statusline = "%!v:lua.native_statusline()"

-- Redraw on diagnostics / git changes so the line stays current.
local grp = api.nvim_create_augroup("NativeStatusline", { clear = true })
api.nvim_create_autocmd({ "DiagnosticChanged", "LspAttach", "LspDetach", "User" }, {
  group = grp,
  pattern = "*",
  callback = function(ev)
    if ev.event == "User" and ev.match ~= "GitSignsUpdate" then
      return
    end
    vim.cmd("redrawstatus")
  end,
})
api.nvim_create_autocmd("ColorScheme", { group = grp, callback = link_hl })

-- Debounced whole-buffer scan for trailing space / mixed indent.
local timer = assert(vim.uv.new_timer())
api.nvim_create_autocmd({ "BufWritePost", "TextChanged", "TextChangedI", "BufEnter" }, {
  group = grp,
  callback = function(ev)
    timer:stop()
    timer:start(
      300,
      0,
      vim.schedule_wrap(function()
        if api.nvim_buf_is_valid(ev.buf) then
          scan_warnings(ev.buf)
          vim.cmd("redrawstatus")
        end
      end)
    )
  end,
})
