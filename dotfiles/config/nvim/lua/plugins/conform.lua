return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      -- opts.async = true
      -- opts.timeout_ms = 5000
      -- opts.lsp_fallback = false
      -- opts.format_on_save = {
      --   timeout_ms = 5000,
      --   lsp_fallback = false,
      -- }

      opts.formatters_by_ft["php"] = { "pint" }

      opts.formatters_by_ft["java"] = { "lsp", "trim_whitespace" }

      opts.formatters = vim.tbl_deep_extend("force", opts.formatters or {}, {
        intellij_java_formatter = {
          command = vim.fn.expand("~/Applications/IntelliJ\\ IDEA\\ Ultimate.app/Contents/bin/format.sh"),
          args = {
            -- "-s",
            -- vim.fn.expand("~/work/utils/dotfiles/intellij_codeStyleSettings.xml"),
            "-allowDefaults",
            "$FILENAME",
          },
        },
      })

      -- START java formatter google-java-format --
      -- opts.formatters_by_ft["java"] = { "google-java-format" }
      -- opts.formatters["google-java-format"] = {
      --   -- prepend_args = { "--aosp", "`@{config_file}`" },
      --   prepend_args = { "--aosp" },
      -- }
      -- END java formatter google-java-format --

      -- opts.formatters_by_ft["java"] = { "intellij_java_formatter" }
      -- opts.formatters = {
      --   intellij_java_formatter = {
      --     command = vim.fn.expand("~/Applications/IntelliJ\\ IDEA\\ Ultimate.app/Contents/bin/format.sh"),
      --     args = {
      --       -- "-s",
      --       -- vim.fn.expand("~/work/utils/dotfiles/intellij_codeStyleSettings.xml"),
      --       "-allowDefaults",
      --       "$FILENAME",
      --     },
      --   },
      -- }

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
