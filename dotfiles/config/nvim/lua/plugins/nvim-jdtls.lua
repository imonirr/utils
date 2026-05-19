return {
  {
    "mfussenegger/nvim-jdtls",
    opts = {
      jdtls = {
        settings = {
          java = {
            compiler = {
              pb = {
                -- Set deprecation problems to warning or error
                deprecation = "warning",
                -- Other useful compiler problem configurations:
                terminalDeprecation = "warning",
                forbiddenReference = "warning",
              },
              problem = {
                deprecation = "warning",
                forbiddenReference = "warning",
                terminalDeprecation = "warning",
                unusedImport = "warning",
                discouragedReference = "warning",
              },
            },
            -- Additional settings you might want
            inlayHints = {
              parameterNames = { enabled = "all" },
            },
            -- This ensures the language server compiles the whole project
            autobuild = { enabled = true },
          },
        },
      },
    },
  },
}
