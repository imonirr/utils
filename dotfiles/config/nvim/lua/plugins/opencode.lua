return {
  {
    "nickjvandyke/opencode.nvim",
    version = "*", -- Latest stable release
    dependencies = {
      {
        -- `snacks.nvim` integration is recommended, but optional
        ---@module "snacks" <- Loads `snacks.nvim` types for configuration intellisense
        "folke/snacks.nvim",
        optional = true,
        opts = {
          input = {}, -- Enhances `ask()`
          picker = { -- Enhances `select()`
            actions = {
              opencode_send = function(...)
                return require("opencode").snacks_picker_send(...)
              end,
            },
            win = {
              input = {
                keys = {
                  ["<a-a>"] = { "opencode_send", mode = { "n", "i" } },
                },
              },
            },
          },
          terminal = {}, -- Enables the `snacks` provider
        },
      },
    },
    config = function()
      ---@type opencode.Opts
      vim.g.opencode_opts = {
        -- provider = "github-copilot",
        -- Your configuration, if any; goto definition on the type or field for details
        provider = {
          terminal = {
            focus = true, -- Focus the terminal when opening
            size = { width = 0.6 }, -- 40% of screen width (default is 0.5)
          },
          snacks = {
            focus = true, -- Focus the terminal when opening
            win = {
              width = 0.4, -- 40% of screen width
            },
          },
        },
        opencode = {
          -- Set GitHub Copilot as the provider
          provider = "github",
          -- Set Claude Sonnet 4.5 as the default model
          model = "claude-sonnet-4.5",
          -- Optional: Additional opencode CLI args
          -- Set default agent to plan
          agent = "plan",
          args = {
            "--width",
            "120", -- Set width in columns
          },
        },
      }

      vim.o.autoread = true -- Required for `opts.events.reload`

      -- Register WhichKey group
      local wk = require("which-key")
      wk.add({
        { "<leader>o", group = "Opencode" },
      })

      -- Your keymaps
      vim.keymap.set({ "n", "x" }, "<leader>oo", function()
        require("opencode").ask("", { submit = false })
      end, { desc = "Ask OpenCode" })

      vim.keymap.set({ "n", "x" }, "<leader>oa", function()
        require("opencode").select()
      end, { desc = "Select Action/Prompt" })

      vim.keymap.set({ "n", "x" }, "<leader>os", function()
        require("opencode").command("session.share")
      end, { desc = "Share Session" })

      vim.keymap.set({ "n", "x" }, "<leader>ol", function()
        require("opencode").command("session.select")
      end, { desc = "Select/Load Session" })

      vim.keymap.set({ "n", "x" }, "<leader>on", function()
        require("opencode").command("session.new")
      end, { desc = "New Session" })

      vim.keymap.set({ "n", "x" }, "<leader>ot", function()
        require("opencode").toggle()
      end, { desc = "Toggle OpenCode" })

      -- {
      --   "<leader>oc",
      --   function()
      --     require("opencode").command("session.compact")
      --   end,
      --   desc = "Compact Session (OpenCode)",
      -- },

      -- {
      --   "<leader>or",
      --   function()
      --     require("opencode").prompt("review")
      --   end,
      --   desc = "Review Code (OpenCode)",
      -- },
      -- {
      --   "<leader>of",
      --   function()
      --     require("opencode").prompt("fix")
      --   end,
      --   desc = "Fix Diagnostics (OpenCode)",
      -- },
      -- {
      --   "<leader>oe",
      --   function()
      --     require("opencode").prompt("explain")
      --   end,
      --   desc = "Explain Code (OpenCode)",
      -- },
      -- {
      --   "<leader>od",
      --   function()
      --     require("opencode").prompt("document")
      --   end,
      --   desc = "Document Code (OpenCode)",
      -- },
      --

      -- Recommended/example keymaps
      vim.keymap.set({ "n", "x" }, "<C-a>", function()
        require("opencode").ask("@this: ", { submit = true })
      end, { desc = "Ask opencode…" })
      vim.keymap.set({ "n", "x" }, "<C-x>", function()
        require("opencode").select()
      end, { desc = "Execute opencode action…" })
      vim.keymap.set({ "n", "t" }, "<C-.>", function()
        require("opencode").toggle()
      end, { desc = "Toggle opencode" })

      vim.keymap.set({ "n", "x" }, "go", function()
        return require("opencode").operator("@this ")
      end, { desc = "Add range to opencode", expr = true })
      vim.keymap.set("n", "goo", function()
        return require("opencode").operator("@this ") .. "_"
      end, { desc = "Add line to opencode", expr = true })

      vim.keymap.set("n", "<S-C-u>", function()
        require("opencode").command("session.half.page.up")
      end, { desc = "Scroll opencode up" })
      vim.keymap.set("n", "<S-C-d>", function()
        require("opencode").command("session.half.page.down")
      end, { desc = "Scroll opencode down" })

      -- You may want these if you use the opinionated `<C-a>` and `<C-x>` keymaps above — otherwise consider `<leader>o…` (and remove terminal mode from the `toggle` keymap)
      vim.keymap.set("n", "+", "<C-a>", { desc = "Increment under cursor", noremap = true })
      vim.keymap.set("n", "-", "<C-x>", { desc = "Decrement under cursor", noremap = true })
    end,
  },
}
