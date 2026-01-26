local bundles = {}

-- Java debug adapter
vim.list_extend(
  bundles,
  vim.split(
    vim.fn.glob(
      vim.fn.stdpath("data")
        .. "/mason/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar"
    ),
    "\n"
  )
)

-- Java test extensions
vim.list_extend(
  bundles,
  vim.split(vim.fn.glob(vim.fn.stdpath("data") .. "/mason/packages/java-test/extension/server/*.jar"), "\n")
)

return {
  {
    "mfussenegger/nvim-jdtls",
    ft = { "java" },
    opts = function(_, opts)
      opts.init_options = opts.init_options or {}
      opts.init_options.bundles = bundles
    end,
  },
}
