local M = {}


function M.setup()
  vim.g.loaded_netrw = 1
  vim.g.loaded_netrwPlugin = 1

  require("nvim-tree").setup({
    sort_by = "case_sensitive",
    view = {
      adaptive_size = true,
      number = true,
      width = 20,
      mappings = {
        list = {
          { key = "u", action = "dir_up" },
          { key = "/", action = "search" },
        },
      },
    },
    renderer = {
      group_empty = true,
      icons = {
        show = {
          git = true,
          file = false,
          folder = false,
          folder_arrow = true,
        },
        glyphs = {
          folder = {
            arrow_closed = "⏵",
            arrow_open = "⏷",
          },
          git = {
            unstaged = "✗",
            staged = "✓",
            unmerged = "⌥",
            renamed = "➜",
            untracked = "★",
            deleted = "⊖",
            ignored = "◌",
          },
        },
      },
    },
    update_focused_file = {
        enable = true,
        update_root = true,
    },
    filters = {
      dotfiles = false,
    },
  })

  vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>')

end


return M


