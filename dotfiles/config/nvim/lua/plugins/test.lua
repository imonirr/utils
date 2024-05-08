return {
  "nvim-neotest/neotest",
  -- tag = "v3.4.7",
  dependencies = {
    -- "nvim-treesitter/nvim-treesitter",
    -- "haydenmeade/neotest-jest",
    "marilari88/neotest-vitest",
    "thenbe/neotest-playwright",
  },
  keys = {
    {
      "<leader>tl",
      function()
        require("neotest").run.run_last()
      end,
      desc = "Run last test",
    },
    -- {
    --   "<leader>tL",
    --   function()
    --     require("neotest").run.run_last({ strategy = "dap" })
    --   end,
    --   desc = "Debug Last Test",
    -- },
    {
      "<leader>tw",
      "<cmd>lua require('neotest').run.run({ jestCommand = 'jest --watch ' })<cr>",
      desc = "Run Watch",
    },
  },

  opts = function(_, opts)
    table.insert(
      opts.adapters,
      require("neotest-vitest")({
        env = { DEBUG_PRINT_LIMIT = 5000 },
      })
    )

    -- table.insert(
    --   opts.adapters,
    --   require("neotest-playwright")
    -- require("neotest-playwright")({
    --   options = {
    --     persist_project_selection = true,
    --     enable_dynamic_test_discovery = true,
    --     -- is_test_file = function(file_path)
    --     --   -- By default, neotest-playwright only returns true if a file contains one of several file extension patterns.
    --     --   -- See default implementation here: https://github.com/thenbe/neotest-playwright/blob/c036fe39469e06ae70b63479b5bb2ce7d654beaf/src/discover.ts#L25-L47
    --     --   return string.match(file_path, "__test__/playwright")
    --     -- end,
    --   },
    -- })
    -- )
  end,
}
