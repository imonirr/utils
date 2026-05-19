return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "marilari88/neotest-vitest",
      "thenbe/neotest-playwright",
    },
    opts = function(_, opts)
      local vitest = require("neotest-vitest")
      local playwright = require("neotest-playwright").adapter({
        options = {
          persist_project_selection = true,
          enable_dynamic_test_discovery = true,
        },
      })

      -- Save the original functions
      local orig_vitest_is_test = vitest.is_test_file
      local orig_playwright_is_test = playwright.is_test_file

      -- Playwright ONLY claims files that have "__tests__/playwright" in their absolute path
      playwright.is_test_file = function(file_path)
        if string.find(file_path, "__tests__/playwright", 1, true) then
          return orig_playwright_is_test(file_path)
        end
        return false
      end

      -- Vitest claims files normally, BUT rejects them if they are in the playwright directory
      vitest.is_test_file = function(file_path)
        if string.find(file_path, "__tests__/playwright", 1, true) then
          return false
        end
        return orig_vitest_is_test(file_path)
      end

      -- Add the modified adapters to the list
      opts.adapters = opts.adapters or {}
      table.insert(opts.adapters, vitest)
      table.insert(opts.adapters, playwright)
    end,
  },
}
