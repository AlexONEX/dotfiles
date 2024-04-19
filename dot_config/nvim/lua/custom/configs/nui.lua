-- nui.lua
local M = {}

-- Configuración básica de nui.nvim
M.setup = function()
  -- Ejemplo de configuración para un componente de nui.nvim, como un Popup
  local Popup = require "nui.popup"
  local event = require("nui.utils.autocmd").event

  M.popup_example = Popup {
    border = {
      style = "rounded", -- Estilo de borde puede ser "single", "double", "rounded", etc.
      text = {
        top = " Ejemplo ",
        top_align = "center",
      },
    },
    position = "50%",
    size = {
      width = "80%",
      height = "60%",
    },
    enter = true,
    focusable = true,
    zindex = 50,
    relative = "editor",
    buf_options = {
      modifiable = true,
      readonly = false,
    },
  }

  -- Ejemplo de evento para cerrar el Popup
  M.popup_example:on(event.BufLeave, function()
    M.popup_example:unmount()
  end)

  -- Función para montar y mostrar el Popup
  function M.show_popup_example()
    M.popup_example:mount()

    -- Coloca el cursor en el Popup
    vim.api.nvim_set_current_win(M.popup_example.win_id)
  end

  -- Agrega más configuraciones de nui.nvim aquí según sea necesario
end

return M
