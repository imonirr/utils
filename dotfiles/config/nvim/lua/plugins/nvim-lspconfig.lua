return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        vtsls = {
          on_attach = function(client, bufnr)
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
          end,
        },
        jdtls = {
          settings = {
            java = {
              project = {},
              excludePaths = { "target" },
            },
          },
        },
        bicep = {}, -- Add this line for Bicep LSP support
      },
    },
  },
}
