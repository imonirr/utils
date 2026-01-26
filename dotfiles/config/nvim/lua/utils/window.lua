local M = {}

function M.open_modal(path)
  local buf = vim.fn.bufadd(path)
  vim.fn.bufload(buf)

  local width = math.floor(vim.o.columns * 0.75)
  local height = math.floor(vim.o.lines * 0.75)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    border = "rounded",
  })

  -- Modal-like behavior
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].modifiable = true
  vim.bo[buf].filetype = "markdown"

  -- Close with q or Esc
  vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = buf, silent = true })
  vim.keymap.set("n", "<Esc>", "<cmd>close<CR>", { buffer = buf, silent = true })
end

return M
