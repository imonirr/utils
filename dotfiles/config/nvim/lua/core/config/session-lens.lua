local M = {}


function M.setup()
  require('session-lens').setup { }
  --[[
    prompt_title = 'YEAH SESSIONS',
    path_display = {'shorten'},
    theme = 'ivy', -- default is dropdown
    theme_conf = { border = false },
    previewer = true
  }
  --]]

  vim.keymap.set('n', '<leader>ss', ':SearchSession<CR>')
end

return M
