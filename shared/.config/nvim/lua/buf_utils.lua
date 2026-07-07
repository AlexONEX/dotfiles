-- Buffer navigation (migrated from autoload/buf_utils.vim)

local M = {}

local function get_buf_nums()
  local bufinfos = vim.fn.getbufinfo({ buflisted = 1 })
  local nums = {}
  for _, info in ipairs(bufinfos) do
    table.insert(nums, info.bufnr)
  end
  return nums
end

--- Go to buffer by count or direction.
function M.go_to_buffer(count, direction)
  if count == 0 then
    if direction == "forward" then
      vim.cmd("bnext")
    elseif direction == "backward" then
      vim.cmd("bprevious")
    else
      vim.notify("Bad argument " .. tostring(direction), vim.log.levels.ERROR)
    end
    return
  end
  -- Check the validity of buffer number
  local buf_nums = get_buf_nums()
  local found = false
  for _, n in ipairs(buf_nums) do
    if n == count then
      found = true
      break
    end
  end
  if not found then
    vim.notify("Invalid bufnr: " .. count, vim.log.levels.WARN, { title = "nvim-config" })
    return
  end
  if direction == "forward" then
    vim.cmd("buffer " .. count)
  end
end

return M
