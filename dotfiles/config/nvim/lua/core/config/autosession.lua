local M = {}

function M.setup()

  local function restore_nvim_tree()
      local nvim_tree = require('nvim-tree')
      nvim_tree.change_dir(vim.fn.getcwd())
      nvim_tree.refresh()
  end



  require("auto-session").setup {
    log_level = "error",

    cwd_change_handling = {
      auto_session_enable_last_session=true,
      restore_upcoming_session = true, -- already the default, no need to specify like this, only here as an example
      pre_cwd_changed_hook = nil, -- already the default, no need to specify like this, only here as an example
      post_cwd_changed_hook = function() -- example refreshing the lualine status line _after_ the cwd changes
        require("lualine").refresh() -- refresh lualine so the new session name is displayed in the status bar
      end,
    },

    -- TODO not sure if the following works
    postrestore_cmds = {restore_nvim_tree}
  }

  require('lualine').setup{
    options = {
      theme = 'auto',
    },
    sections = {lualine_c = {require('auto-session-library').current_session_name}}
  }

end

return M


