-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "java", "json", "yaml" },
  callback = function()
    vim.b.autoformat = false
  end,
})

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = "java",
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
  end,
})

-- restore tab scoped buffers from scope.nvim with persistent sessions
vim.api.nvim_create_autocmd("SessionLoadPost", {
  callback = function()
    vim.schedule(function()
      require("scope").setup()
    end)
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "dbui",
  callback = function(event)
    local is_expanded = false
    local original_width = nil

    vim.keymap.set("n", "e", function()
      local win = vim.api.nvim_get_current_win()

      if is_expanded then
        local target_width = original_width or vim.g.db_ui_winwidth or 30
        vim.api.nvim_win_set_width(win, target_width)
        is_expanded = false
      else
        original_width = vim.api.nvim_win_get_width(win)

        local max_len = 0
        local lines = vim.api.nvim_buf_get_lines(event.buf, 0, -1, false)
        for _, line in ipairs(lines) do
          local len = vim.fn.strdisplaywidth(line)
          if len > max_len then
            max_len = len
          end
        end

        local target_width = math.max(max_len + 4, 30)
        vim.api.nvim_win_set_width(win, target_width)
        is_expanded = true
      end
    end, { buffer = event.buf, silent = true, desc = "Toggle DBUI sidebar width" })
  end,
})
