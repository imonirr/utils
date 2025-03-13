return {
  "mfussenegger/nvim-jdtls",
  -- opts will be merged with the parent spec
  -- opts = function(_, opts)
  --   table.insert(opts.settings, {
  --     java = {
  --       format = {
  --         settings = { url = "/Users/monir/eclipse-java-google-style.xml" },
  --       },
  --     },
  --   })
  -- end,
  -- opts = function(_, opts)
  opts = {
    settings = {
      java = {
        format = {
          settings = { url = "/Users/monir/eclipse-java-google-style.xml" },
        },
      },
    },
  },
  --   return opts
  -- end,
}
