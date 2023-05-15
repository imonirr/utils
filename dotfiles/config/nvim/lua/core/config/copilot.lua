
local M = {}

function M.setup()
  vim.g.copilot_filetypes = {
    ["*"] = false,
    ["javascript"] = true,
    ["typescript"] = true,
    ["typescriptreact"] = true,
    ["markdown"] = true,
    ["lua"] = true,
    ["python"] = true,
    -- ["java"] = true,
  }

  vim.g.copilot_no_tab_map = true
  vim.api.nvim_set_keymap("i", "<C-H>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
  vim.api.nvim_set_keymap("i", "<C-K>", 'copilot#Previous()', { silent = true, expr = true })
  vim.api.nvim_set_keymap("i", "<C-J>", 'copilot#Next()', { silent = true, expr = true })

  -- require("copilot").setup({
  --   suggestion = { enabled = false },
  --   panel = { enabled = false },
  -- })


end

return M


