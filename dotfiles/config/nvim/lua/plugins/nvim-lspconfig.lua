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

        yamlls = {
          settings = {
            yaml = {
              schemas = {
                ["https://json.schemastore.org/kustomization.json"] = "kustomization.{yml,yaml}",
                ["https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.30.0/all.json"] = "/*.k8s.{yml,yaml}",
                kubernetes = "/*.{yml,yaml}",
              },
              validate = true,
              completion = true,
              hover = true,
            },
          },
        },
      },
    },
  },
}
