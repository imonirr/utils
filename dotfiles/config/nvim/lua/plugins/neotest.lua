return {
  -- {
  --   "rcasia/neotest-java",
  --   ft = "java",
  --   dependencies = {
  --     "mfussenegger/nvim-jdtls",
  --     "mfussenegger/nvim-dap", -- for the debugger
  --     "rcarriga/nvim-dap-ui", -- recommended
  --     "theHamsta/nvim-dap-virtual-text", -- recommended
  --   },
  --   init = function()
  --     -- override the default keymaps.
  --     -- needed until neotest-java is integrated in LazyVim
  --     local keys = require("lazyvim.plugins.lsp.keymaps").get()
  --     -- run test file
  --     keys[#keys + 1] = {
  --       "<leader>tt",
  --       function()
  --         require("neotest").run.run(vim.fn.expand("%"))
  --       end,
  --       mode = "n",
  --     }
  --     -- run nearest test
  --     keys[#keys + 1] = {
  --       "<leader>tr",
  --       function()
  --         require("neotest").run.run()
  --       end,
  --       mode = "n",
  --     }
  --     -- debug test file
  --     keys[#keys + 1] = {
  --       "<leader>tD",
  --       function()
  --         require("neotest").run.run({ strategy = "dap" })
  --       end,
  --       mode = "n",
  --     }
  --     -- debug nearest test
  --     keys[#keys + 1] = {
  --       "<leader>td",
  --       function()
  --         require("neotest").run.run({ vim.fn.expand("%"), strategy = "dap" })
  --       end,
  --       mode = "n",
  --     }
  --   end,
  -- },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "marilari88/neotest-vitest",
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = function(_, opts)
      opts.adapters = {
        ["neotest-vitest"] = {
          -- env = { DEBUG_PRINT_LIMIT = 20000 },
        },
        -- ["neotest-java"] = {
        --   -- config here
        --   --
        --   incremental_build = true,
        -- },

        -- ["neotest-playwright"] = {
        --   persist_project_selection = true,
        --   enable_dynamic_test_discovery = true,
        --   is_test_file = function(file_path)
        --     -- By default, neotest-playwright only returns true if a file contains one of several file extension patterns.
        --     -- See default implementation here: https://github.com/thenbe/neotest-playwright/blob/c036fe39469e06ae70b63479b5bb2ce7d654beaf/src/discover.ts#L25-L47
        --     return string.match(file_path, "__test__/playwright")
        --   end,
        -- },
      }
    end,
  },
}
--  from neotest-playwirght documentation config example with lazyvim
-- {
-- 	'nvim-neotest/neotest',
-- 	dependencies = {
-- 		'thenbe/neotest-playwright',
--       dependencies = 'nvim-telescope/telescope.nvim',
-- 	},
-- 	config = function()
-- 		require('neotest').setup({
-- 			adapters = {
-- 				require('neotest-playwright').adapter({
-- 					options = {
-- 						persist_project_selection = true,
-- 						enable_dynamic_test_discovery = true,
-- 					},
-- 				}),
-- 			},
-- 		})
-- 	end,
-- }
