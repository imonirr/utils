return {
  "nvim-neotest/neotest",
  dependencies = {
    "marilari88/neotest-vitest",
    "thenbe/neotest-playwright",
    -- "nvim-treesitter/nvim-treesitter",
  },
  opts = function(_, opts)
    opts.adapters = {
      ["neotest-vitest"] = {},

      ["neotest-playwright"] = {
        persist_project_selection = true,
        enable_dynamic_test_discovery = true,
        is_test_file = function(file_path)
          -- By default, neotest-playwright only returns true if a file contains one of several file extension patterns.
          -- See default implementation here: https://github.com/thenbe/neotest-playwright/blob/c036fe39469e06ae70b63479b5bb2ce7d654beaf/src/discover.ts#L25-L47
          return string.match(file_path, "__test__/playwright")
        end,
      },
    }
  end,
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
