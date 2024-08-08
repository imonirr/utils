-- config not working
return {
  "rcarriga/nvim-dap-ui",
  opts = {
    layouts = {
      {
        elements = {
          -- Elements can be strings or table with id and size keys.
          { id = "scopes", size = 0.33 },
          "breakpoints",
          -- "stacks",
          -- "watches",
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
