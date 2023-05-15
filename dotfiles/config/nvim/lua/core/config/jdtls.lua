local M = {}

function M.setup()
  --
  -- local config = {
  --     -- cmd = {'/path/to/jdt-language-server/bin/jdtls'},
  --     cmd = {'/home/monir/.local/bin/jdtls/bin'},
  --     root_dir = vim.fs.dirname(vim.fs.find({'gradlew', '.git', 'mvnw'}, { upward = true })[1]),
  -- }
  -- require('jdtls').start_or_attach(config)

  -- local ok, jdtls = require('jdtls')
  local jdtls = require('jdtls')
  -- See `:help vim.lsp.start_client` for an overview of the supported `config` options.
  local config = {
    -- The command that starts the language server
    -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
    -- java \
    --       -Declipse.application=org.eclipse.jdt.ls.core.id1 \
    --       -Dosgi.bundles.defaultStartLevel=4 \
    --       -Declipse.product=org.eclipse.jdt.ls.core.product \
    --       -Dlog.level=ALL \
    --       -Xmx1G \
    --       --add-modules=ALL-SYSTEM \
    --       --add-opens java.base/java.util=ALL-UNNAMED \
    --       --add-opens java.base/java.lang=ALL-UNNAMED \
    --       -jar ./plugins/org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar \
    --       -configuration ./config_linux \
    --       -data ~/.data
    cmd = {

      -- 💀
      'java', -- or '/path/to/java17_or_newer/bin/java'
              -- depends on if `java` is in your $PATH env variable and if it points to the right version.

      '-Declipse.application=org.eclipse.jdt.ls.core.id1',
      '-Dosgi.bundles.defaultStartLevel=4',
      '-Declipse.product=org.eclipse.jdt.ls.core.product',
      '-Dlog.protocol=true',
      '-Dlog.level=ALL',
      '-Xmx1g',
      '--add-modules=ALL-SYSTEM',
      '--add-opens', 'java.base/java.util=ALL-UNNAMED',
      '--add-opens', 'java.base/java.lang=ALL-UNNAMED',

      -- 💀
      '-jar', '/home/monir/.local/bin/jdtls/plugins/org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar',
          -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^                                       ^^^^^^^^^^^^^^
          -- Must point to the                                                     Change this to
          -- eclipse.jdt.ls installation                                           the actual version


      -- 💀
      '-configuration', '/home/monir/.local/bin/jdtls/config_linux',
                      -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^        ^^^^^^
                      -- Must point to the                      Change to one of `linux`, `win` or `mac`
                      -- eclipse.jdt.ls installation            Depending on your system.


      -- 💀
      -- See `data directory configuration` section in the README
      '-data', '/home/monir/.local/data'
    },




    -- 💀
    -- This is the default if not provided, you can remove it. Or adjust as needed.
    -- One dedicated LSP server & client will be started per unique root_dir
    root_dir = require('jdtls.setup').find_root({'.git', 'mvnw', 'gradlew'}),

    -- Here you can configure eclipse.jdt.ls specific settings
    -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
    -- for a list of options
    settings = {
      java = {
            signatureHelp = {enabled = true},
            import = {enabled = true},
            rename = {enabled = true},
            configuration = {
              runtimes = {
                {
                  name = "JavaSE-11",
                  path = "/usr/lib/jvm/java-11-openjdk-amd64",
                },
                {
                  name = "JavaSE-8",
                  path = "/usr/lib/jvm/java-8-openjdk-amd64",
                },
              },
            },
      }
    },

    -- Language server `initializationOptions`
    -- You need to extend the `bundles` with paths to jar files
    -- if you want to use additional eclipse.jdt.ls plugins.
    --
    -- See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
    --
    -- If you don't plan on using the debugger or other eclipse.jdt.ls plugins you can remove this
    init_options = {
      bundles = {}
    },
  }
  -- This starts a new client & server,
  -- or attaches to an existing client & server depending on the `root_dir`.
  -- if ok then
    jdtls.start_or_attach(config)
  -- end



end

return M
