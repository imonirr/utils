
local M = {}


function M.setup()
  require('lualine').setup {
    options = {
      icons_enabled = true,
      theme = 'gruvbox',
    },
    sections = {
      lualine_a = {
        {
          'filename',
          path = 0,
        }
      }
    }
  }
end

return M


