-- local config_file = vim.fn.expand("~/Work/eclipse-java-google-style.xml")
-- return {
--   {
--     "stevearc/conform.nvim",
--     optional = true,
--     opts = {
--       formatters_by_ft = {
--         php = { { "pint", "php_cs_fixer" } },
--         java = { "google-java-format" },
--       },
--       formatters = {
--         "google-java-format" = {
--           prepend_args = { "--aosp" },
--         },
--       },
--     },
--   },
-- }

return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      -- opts.formatters_by_ft["java"] = { "my_java_formatter" }
      -- opts.formatters = {
      --   my_java_formatter = {
      --     command = "clang-format",
      --     -- args = '--style="{BasedOnStyle: Microsoft, IndentWidth: 4}"',
      --     args = '--style="{BasedOnStyle: InheritParentConfig, IndentWidth: 4}"',
      --   },
      -- }
      opts.formatters_by_ft["java"] = { "google-java-format" }
      opts.formatters["google-java-format"] = {
        -- prepend_args = { "--aosp", "`@{config_file}`" },
        prepend_args = { "--aosp" },
      }
      opts.formatters_by_ft["php"] = { "pint" }

      return opts
    end,
  },
  {
    -- Remove phpcs linter.
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        php = {},
      },
    },
  },
}
