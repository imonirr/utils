local M = {}

function M.setup()
  vim.keymap.set('n', '<leader>gs', ':Git status<CR>')
  vim.keymap.set('n', '<leader>gd', ':Git diff<CR>')
  vim.keymap.set('n', '<leader>gc', ':Git commit<CR>')
  vim.keymap.set('n', '<leader>gb', ':Git blame<CR>')
  vim.keymap.set('n', '<leader>gl', ':Git log<CR>')
  vim.keymap.set('n', '<leader>gi', ':Git add -p %<CR>')
  --[[
  vim.keymap.set('n', '<leader>gp', ':Git push<CR>')
  vim.keymap.set('n', '<leader>gr', ':Gitread<CR>')
  vim.keymap.set('n', '<leader>gw', ':Gitwrite<CR>')
  vim.keymap.set('n', '<leader>ge', ':Gedit<CR>')
  vim.keymap.set('n', '<leader>gg', ':SignifyToggle<CR>')
  --]]
end

return M
