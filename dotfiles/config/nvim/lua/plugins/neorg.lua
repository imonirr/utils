return {
  "nvim-neorg/neorg",
  dependencies = { "luarocks.nvim" },
  lazy = false, -- Disable lazy loading as some `lazy.nvim` distributions set `lazy = true` by default
  version = "*", -- Pin Neorg to the latest stable release

  -- optional from other places
  build = ":Neorg sync-parsers",
  -- event = "VeryLazy",
  opts = {
    load = {
      ["core.defaults"] = {},
      ["core.concealer"] = {},
      ["core.keybinds"] = {},
      ["core.completion"] = {
        config = {
          engine = "nvim-cmp",
        },
      },
      ["core.journal"] = {},
      ["core.dirman"] = {
        config = {
          workspaces = {
            work = "~/Dropbox/neorg/work",
          },
        },
      },
    },
  },
}
