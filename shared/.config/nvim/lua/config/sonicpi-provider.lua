-- blink v1 no tiene compat layer para nvim-cmp; este modulo adapta cmp-sonicpi a la interfaz de blink
local M = {}

function M.new(_opts, _config)
  return setmetatable({}, { __index = M })
end

function M:get_trigger_characters()
  return { ":", " ", "," }
end

function M:get_completions(context, on_response)
  -- context.cursor = {1-based row, 0-based col} (nvim_win_get_cursor)
  local cursor = context.cursor
  local params = {
    context = {
      cursor_before_line = context.line:sub(1, cursor[2]),
      cursor = { line = cursor[1] - 1, col = cursor[2] },
    },
  }

  local cmp_source = require("cmp-sonicpi.source").new()
  local done = false
  cmp_source.complete(nil, params, function(resp)
    done = true
    on_response { items = resp and resp.items or {}, is_incomplete_forward = false, is_incomplete_backward = false }
  end)

  -- ponytail: fuente 100% sincrona; done=false = contexto sin match
  if not done then
    on_response { items = {}, is_incomplete_forward = false, is_incomplete_backward = false }
  end
end

return M
