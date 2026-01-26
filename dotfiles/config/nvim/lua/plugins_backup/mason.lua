return {
  {
    "mason-org/mason.nvim",
    opts = {
      registries = {
        "github:mason-org/mason-registry",
      },
      registry = {
        overrides = {
          jdtls = {
            version = "1.38.0", -- or whatever version you want
          },
        },
      },
    },
  },
}
