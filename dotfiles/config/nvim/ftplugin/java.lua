local config = require("lsp.java").make_jdtls_config()

local pkg_status, jdtls = pcall(require,"jdtls")
if not pkg_status then
  vim.notify("unable to load nvim-jdtls", 1)
  return
end
jdtls.start_or_attach(config)
