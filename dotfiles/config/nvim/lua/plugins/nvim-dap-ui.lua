-- config not working
return {
  "rcarriga/nvim-dap-ui",
  opts = {
    layouts = {
      {
        elements = {
          -- Elements can be strings or table with id and size keys.
          -- { id = "scopes", size = 0.33 },
          "scopes",
          { id = "breakpoints", size = 0.25 },
          -- "watches",
          "stacks",
        },
        size = 60, -- 40 columns
        position = "left",
      },
      -- {
      --   elements = {
      --     "repl",
      --     "console",
      --   },
      --   size = 0.25, -- 25% of total lines
      --   position = "bottom",
      -- },
    },
  },
}
