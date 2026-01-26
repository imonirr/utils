local M = {}

function M.open_kulala_response()
  local path = vim.fn.expand("~/.cache/nvim/kulala/body.txt")

  if vim.fn.filereadable(path) ~= 1 then
    vim.notify("Kulala response file not found", vim.log.levels.WARN)
    return
  end

  -- Create buffer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(buf, "KulalaResponse")

  -- Load file content
  local lines = vim.fn.systemlist("jq . " .. path)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  -- Set buffer options
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "json" -- change if needed
  vim.bo[buf].modifiable = false

  -- Window size
  local width = math.floor(vim.o.columns * 0.85)
  local height = math.floor(vim.o.lines * 0.85)

  -- Open floating window
  vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
  })
end

return M
