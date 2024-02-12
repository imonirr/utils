return {
  "nvim-neotest/neotest",
  tag = "v3.4.7",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    -- "haydenmeade/neotest-jest",
    "marilari88/neotest-vitest",
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
    -- table.insert(
    --   opts.adapters,
    --   require("neotest-jest")({
    --     jestCommand = "npm test--",
    --     jestConfigFile = "jest.config.js",
    --     env = { CI = "true" },
    --     cwd = function()
    --       return vim.fn.getcwd()
    --     end,
    --   })
    -- )
    table.insert(opts.adapters, require("neotest-vitest"))
  end,
}
