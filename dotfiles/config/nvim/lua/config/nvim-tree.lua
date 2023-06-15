-- require("nvim-tree").setup({
--   disable_netrw = true,
--   hijack_netrw = true,
--   view = {
--     adaptive_size = true,
--     float = {
--       enable = true,
--     },
--   },
-- })

  vim.g.loaded_netrw = 1
  vim.g.loaded_netrwPlugin = 1

  local function opts(desc)
    return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end
local function on_attach(bufnr)
  local api = require('nvim-tree.api')


      -- vim.keymap.set('n', "<leader>nn", "<cmd>NvimTreeToggle<cr>", "Open file browser")
      -- vim.keymap.set('n', "<leader>nf", "<cmd>NvimTreeFindFile<cr>", "Find in file browser")

      -- Default mappings. Feel free to modify or remove as you wish.
      --
      -- BEGIN_DEFAULT_ON_ATTACH
    api.config.mappings.default_on_attach(bufnr)
      -- END_DEFAULT_ON_ATTACH

  -- Mappings migrated from view.mappings.list
  vim.keymap.set('n', 'u', api.tree.change_root_to_parent, opts('Dir Up'))
  --
  -- You will need to insert "your code goes here" for any mappings with a custom action_cb
  -- vim.keymap.set('n', 'A', api.tree.expand_all, opts('Expand All'))
  -- vim.keymap.set('n', '?', api.tree.toggle_help, opts('Help'))
  -- vim.keymap.set('n', 'C', api.tree.change_root_to_node, opts('CD'))
  vim.keymap.set('n', 'P', function()
    local node = api.tree.get_node_under_cursor()
    print(node.absolute_path)
  end, opts('Print Node Path'))

  vim.keymap.set('n', 'Z', api.node.run.system, opts('Run System'))
end



  require("nvim-tree").setup({
    on_attach = on_attach,
    sort_by = "case_sensitive",
    view = {
      adaptive_size = true,
      number = true,
      width = 20,
      -- mappings = {
      --   list = {
      --     { key = "u", action = "dir_up" },
      --     { key = "/", action = "search" },
      --   },
      -- },
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
    update_cwd = true,
    update_focused_file = {
        enable = true,
        update_root = true,
    },
    filters = {
      dotfiles = false,
    },
      actions = {
        open_file = {
          quit_on_open = true,
        }
      }
  })


vim.keymap.set('n', '<leader>e', ':NvimTreeFindFile<CR>', opts('[E]xplorer'))
  -- vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>')
