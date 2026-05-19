return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- harper_ls = {
        --   filetypes = { "markdown", "typescript", "javascript", "java", "lua" },
        --   settings = {
        --     ["harper-ls"] = {
        --       diagnosticSeverity = "warning",
        --       linters = {
        --         SpelledDirectly = true,
        --         AnA = true,
        --         SentenceCapitalization = false,
        --         UnclosedQuotes = true,
        --       },
        --     },
        --   },
        -- },

        eslint = {

          on_attach = function(client, _bufnr)
            client.server_capabilities.documentFormattingProvider = true
          end,
        },
        tsserver = {
          on_attach = function(client, _bufnr)
            client.server_capabilities.documentFormattingProvider = false
          end,
        },
        vtsls = {
          on_attach = function(client, _bufnr)
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
          end,
        },
        jdtls = {
          settings = {
            java = {
              project = {},
              excludePaths = { "target" },
              -- saveActions = {
              --   organizeImports = true,
              -- },
              -- autobuild = { enabled = true }, -- Ensure this is true
              -- import = {
              --   gradle = { enabled = true },
              --   maven = { enabled = true },
              -- },
              -- format = { enabled = true },
              -- -- This is the section you need:
              -- configuration = {
              --   updateBuildConfiguration = "interactive",
              --   runtimes = { ... }, -- your runtimes here
              -- },
              -- errors = {
              --   incompleteClasspath = { severity = "warning" },
              -- },
              -- REQUIRED FOR DEPRECATION WARNINGS:
              compiler = {
                problem = {
                  deprecation = "warning", -- Standard deprecation
                  forbiddenReference = "warning", -- Accessing restricted internal APIs
                  unusedImport = "warning", -- Clean up imports
                  discouragedReference = "warning", -- Discouraged but not forbidden
                },
              },
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
      -- setup = {
      --   eslint = function()
      --     require("lazyvim.util").lsp.on_attach(function(client)
      --       if client.name == "eslint" then
      --         client.server_capabilities.documentFormattingProvider = true
      --       elseif client.name == "tsserver" then
      --         client.server_capabilities.documentFormattingProvider = false
      --       end
      --     end)
      --   end,
      -- },
    },
  },
}
