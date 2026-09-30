local M = {}

-- does not work as expected, but leaving it here for now in case I want to try again later
-- Simple auto-save function that can be called via Autocmd
function M.update_buffer(event)
  require("utils") -- ensure global `utils` is loaded

  local buf = event.buf
  local writable_buffer = vim.bo[buf].modifiable and vim.bo[buf].buftype == ""
  local file_exists = vim.api.nvim_buf_get_name(buf) ~= ""
  local saved_recently = (vim.b[buf].timestamp or 0) == vim.fn.localtime()
  local being_formatted = (vim.b[buf].saving_format or false)

  if writable_buffer and file_exists and not saved_recently and not being_formatted then
    vim.api.nvim_buf_call(buf, function()
      vim.cmd("silent update")
    end)
    vim.b[buf].timestamp = vim.fn.localtime()
    utils.print_and_clear("Saved " .. vim.fn.strftime("%H:%M:%S"), 1300)
  end
end

return M
