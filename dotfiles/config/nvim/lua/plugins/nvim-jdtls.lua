return {
  {
    "mfussenegger/nvim-jdtls",
    opts = function(_, opts)
      -- 1. Inject the git worktree dynamic project naming fix
      opts.project_name = function(root_dir)
        if not root_dir then
          return nil
        end

        local parent = vim.fs.basename(vim.fs.dirname(root_dir))
        local current = vim.fs.basename(root_dir)

        -- Fallback guard for projects opened at system root
        if not parent or parent == "" or parent == "/" then
          return current
        end

        -- Combines parent folder name and branch folder name (e.g., "my-project_main")
        return parent .. "_" .. current
      end

      -- Mirror `.mvn/maven.config` (--global-settings .mvn/settings.xml), which jdtls ignores
      local orig_root_dir = opts.root_dir
      opts.root_dir = function(path)
        local root = orig_root_dir(path)
        local global = root and (root .. "/.mvn/settings.xml")
        opts.settings = opts.settings or {}
        opts.settings.java = opts.settings.java or {}
        opts.settings.java.configuration = opts.settings.java.configuration or {}
        opts.settings.java.configuration.maven = {
          userSettings = vim.fn.expand("~/.m2/settings.xml"),
          globalSettings = (global and vim.uv.fs_stat(global)) and global or vim.NIL,
        }
        return root
      end

      -- 2. Safely merge your custom compiler and plugin settings
      opts.jdtls = vim.tbl_deep_extend("force", opts.jdtls or {}, {
        settings = {
          java = {
            compiler = {
              pb = {
                deprecation = "warning",
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
            inlayHints = {
              parameterNames = { enabled = "all" },
            },
            autobuild = { enabled = true },
          },
        },
      })

      -- 3. Return the fully loaded configuration back to LazyVim
      return opts
    end,
  },
}
