return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.async = true
      opts.timeout_ms = 10000
      opts.lsp_fallback = true

      opts.formatters_by_ft["rust"] = { "rustfmt" }

      opts.formatters_by_ft["php"] = { "pint" }

      opts.formatters_by_ft["java"] = { "lsp", "trim_whitespace" }
      -- opts.formatters_by_ft["java"] = { "intellij_java_formatter" }

      opts.formatters = vim.tbl_deep_extend("force", opts.formatters or {}, {
        lsp = {
          format = function(args)
            vim.schedule(function()
              vim.lsp.buf.format({
                async = true,
                bufnr = args.buf,
                timeout_ms = 10000,
              })
            end)
          end,
        },
        -- spotless = {
        --   command = "mvn spotless:apply",
        -- },
        intellij_java_formatter = {
          command = vim.fn.expand("~/Applications/IntelliJ\\ IDEA\\ Ultimate.app/Contents/bin/format.sh"),
          -- command = vim.fn.expand("~/bin/intellij_format.sh"),
          stdin = false,
          args = { --"$FILENAME" },
            -- "-s",
            -- vim.fn.expand("~/work/utils/dotfiles/intellij_codeStyleSettings.xml"),
            "-allowDefaults",
            "$FILENAME",
          },
          timeout = 20000, -- Add this line
        },
      })

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
