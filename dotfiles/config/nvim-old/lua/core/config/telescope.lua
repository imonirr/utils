local M = {}


function  M.setup()
  local builtin = require('telescope.builtin')

  require("telescope").setup({})

  -- Load extensions
  -- require("telescope").load_extension("media_files")
  -- require("telescope").load_extension("file_browser")


  vim.keymap.set('n', '<c-p>', builtin.git_files, {})
  vim.keymap.set('n', '<Space><Space>', builtin.oldfiles, {})
  vim.keymap.set('n', '<Space>fg', builtin.live_grep, {})
  vim.keymap.set('n', '<Space>fh', builtin.find_files, {})

end

return M
