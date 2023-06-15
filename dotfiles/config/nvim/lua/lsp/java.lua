local home = os.getenv('HOME')
local jdtls = require('jdtls')
local root_markers = {'gradlew', 'mvnw', '.git'}
local root_dir = require('jdtls.setup').find_root(root_markers)
local workspace_folder = home .. "/.local/share/eclipse/" .. vim.fn.fnamemodify(root_dir, ":p:h:t")

local remap = require("me.util").remap

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  jdtls.setup_dap({ hotcodereplace = 'auto' })
  jdtls.setup.add_commands()

  -- Default keymaps
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  require("lsp.defaults").on_attach(client, bufnr)

  -- Java extensions
  remap("n", "<C-o>", jdtls.organize_imports, bufopts, "Organize imports")
  remap("n", "<leader>vc", jdtls.test_class, bufopts, "Test class (DAP)")
  remap("n", "<leader>vm", jdtls.test_nearest_method, bufopts, "Test method (DAP)")
  remap("n", "<space>ev", jdtls.extract_variable, bufopts, "Extract variable")
  remap("n", "<space>ec", jdtls.extract_constant, bufopts, "Extract constant")
  remap("v", "<space>em", [[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]], bufopts, "Extract method")
end

local bundles = {
  -- vim.fn.glob(home .. '/.m2/repository/com/microsoft/java/com.microsoft.java.debug.tp/0.45.0/*.jar'),
  vim.fn.glob(home .. '/.local/share/nvim/mason/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-0.46.0.jar'),
}
-- vim.list_extend(bundles, vim.split(vim.fn.glob(home .. '/Projects/vscode-java-test/server/*.jar'), "\n"))
vim.list_extend(bundles, vim.split(vim.fn.glob(home .. '/.local/share/nvim/mason/share/java-test/*.jar'), "\n"))

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

local config = {
  flags = {
    debounce_text_changes = 80,
  },
  capabilities = capabilities,
  on_attach = on_attach,
  init_options = {
    bundles = bundles
  },
  root_dir = root_dir,
  settings = {
    java = {
      signatureHelp = { enabled = true },
      contentProvider = { preferred = 'fernflower' },
      completion = {
        favoriteStaticMembers = {
          "org.hamcrest.MatcherAssert.assertThat",
          "org.hamcrest.Matchers.*",
          "org.hamcrest.CoreMatchers.*",
          "org.junit.jupiter.api.Assertions.*",
          "java.util.Objects.requireNonNull",
          "java.util.Objects.requireNonNullElse",
          "org.mockito.Mockito.*"
        },
        filteredTypes = {
          "com.sun.*",
          "io.micrometer.shaded.*",
          "java.awt.*",
          "jdk.*",
          "sun.*",
        },
      },
      sources = {
        organizeImports = {
          starThreshold = 9999;
          staticStarThreshold = 9999;
        },
      },
      codeGeneration = {
        toString = {
          template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}"
        },
        hashCodeEquals = {
          useJava7Objects = true,
        },
        useBlocks = true,
      },
      configuration = {
        runtimes = {
          {
            name = "JavaSE-17",
            path = home .. "/.sdkman/candidates/java/17.0.5-oracle",
          },
        }
      }
    }
  },
  cmd = {
    home .. "/.sdkman/candidates/java/17.0.5-oracle/bin/java",
    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-Xmx1g',
    '--add-modules=ALL-SYSTEM',
    '--add-opens', 'java.base/java.util=ALL-UNNAMED',
    '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
    -- '-javaagent:' .. home .. '/.local/share/eclipse/lombok.jar',
    '-jar', home .. "/.local/bin/jdt-language-server-1.9.0/plugins/org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar",
    '-configuration', home .. "/.local/bin/jdt-language-server-1.9.0/config_linux",
    -- '-jar', vim.fn.glob(home .. "/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar"),
    -- '-configuration', home .. "/.local/share/nvim/mason/packages/jdtls/config_linux",
    '-data', workspace_folder,
  },
}

local M = {}
function M.make_jdtls_config()
  return config
end
return M
