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

      -- START java formatter google-java-format --
      -- opts.formatters_by_ft["java"] = { "google-java-format" }
      -- opts.formatters["google-java-format"] = {
      --   -- prepend_args = { "--aosp", "`@{config_file}`" },
      --   prepend_args = { "--aosp" },
      -- }
      -- END java formatter google-java-format --

      -- START eclipse jdt formatter for java
      -- formatters_by_ft = {
      -- opts.formatters_by_ft["java"] = { "eclipse_jdt" }
      -- opts.formatters["eclipse_jdt"] = {
      --   command = "java",
      --   args = {
      --     "-jar",
      --     "/opt/homebrew/opt/eclipse-jdt/libexec/plugins/org.eclipse.jdt.core_*.jar", -- Adjust path if needed
      --     "-config",
      --     vim.fn.expand("~/.config/eclipse-formatter-config.xml "), -- Change to your config path
      --     "-nosplash",
      --     "-application",
      --     "org.eclipse.jdt.core.JavaCodeFormatter",
      --   },
      --   stdin = false,
      -- }
      -- END eclipse jdt formatter for java
      --
      --
      -- START java formatter clang-format
      -- opts.formatters_by_ft["java"] = { "clang-format" }
      -- opts.formatters["clang-format"] = {
      --   args = {
      --     -- LLVM, GNU, Google, Chromium, Microsoft, Mozilla, WebKit
      --     -- '--style="{BasedOnStyle: google, BreakFunctionDefinitionParameters: false, PenaltyBreakFirstLessLess: 220, PenaltyBreakOpenParenthesis: 200, ObjCBreakBeforeNestedBlockParam: false,  IndentWrappedFunctionNames: false,ColumnLimit: 200, IndentWidth: 4, AllowAllArgumentsOnNextLine: false, AllowAllParametersOfDeclarationOnNextLine: false, AllowShortBlocksOnASingleLine: Always,BraceWrapping: {AfterControlStatement: trueAfterFunction:  true}}"',
      --     "--style=file:/Users/monir/work/utils/dotfiles/.clang-format",
      --   },
      -- }
      -- END java formatter clang-format

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
