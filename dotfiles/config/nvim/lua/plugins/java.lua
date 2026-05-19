return {
  url = "https://gitlab.com/schrieveslaach/sonarlint.nvim",
  dependencies = {
    "mfussenegger/nvim-jdtls",
  },
  ft = { "java" },
  config = function()
    require("sonarlint").setup({
      server = {
        cmd = {
          "sonarlint-language-server",
          -- Ensure you install the sonarlint-language-server via :Mason
          "-stdio",
          "-analyzers",
          -- Point to the java analyzer jar downloaded by Mason
          vim.fn.expand(
            "~/.local/share/nvim/mason/packages/sonarlint-language-server/extension/analyzers/sonarjava.jar"
          ),
        },
      },
      filetypes = { "java" },
    })
  end,
}
