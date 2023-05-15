local M = {}


function M.setup()
  require'nvim-treesitter.configs'.setup {
    ensure_installed = { "lua", "vim", "javascript", "typescript" },

    sync_install = false,
    auto_install = true,
    highlight = {
      enabled = true,
    },
  }
end

return M

