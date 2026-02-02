return {
  {
    "imonirr/avante.nvim",
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    -- ⚠️ must add this setting! ! !
    build = vim.fn.has("win32") ~= 0 and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
      or "make",
    event = "VeryLazy",
    version = false, -- Never set this value to "*"! Never!
    ---@module 'avante'
    ---@type avante.Config
    opts = {
      -- add any opts here
      -- this file can contain specific instructions for your project
      instructions_file = "avante.md",
      -- for example
      provider = "copilot",
      providers = {
        copilot = {
          model = "claude-sonnet-4.5", -- or whichever model you want as default
        },
      },
      behaviour = {
        auto_suggestions = false,
        auto_set_highlight_group = true,
        auto_set_keymaps = true,
        auto_apply_diff_after_generation = false, -- don't auto-apply, let you review
        support_paste_from_clipboard = false,
      },
      -- Disable the suggestion UI completely
      suggestion = {
        enable = false,
      },
      -- Optional: disable inline hints
      hints = {
        enabled = false,
      },
      -- Change the width of the sidebar (default is usually around 30 or 40)
      width = 50, -- Percentage based on available width

      windows = {
        -- Adjust the specific height of the input area
        input = {
          height = 12, -- Increase this from the default (8) for a larger input box
        },
        sidebar_header = {
          align = "center",
          rounded = true,
        },
      },
    },
    -- Disable default mappings
    mappings = {
      ask = nil,
      edit = nil,
      refresh = nil,
      focus = nil,
      toggle = {
        default = nil,
        debug = nil,
        hint = nil,
        suggestion = nil,
      },
    },
    keys = {
      -- Core workflow
      { "<leader>Aa", "<cmd>AvanteToggle<cr>", desc = "Avante Toggle" },
      { "<leader>Ae", "<cmd>AvanteEdit<cr>", mode = { "n", "v" }, desc = "Avante Edit" },
      { "<leader>AA", "<cmd>AvanteAsk<cr>", mode = { "n", "v" }, desc = "Avante Ask (with selection)" },

      -- Model/Provider
      { "<leader>Am", "<cmd>AvanteModels<cr>", desc = "Avante Models" },
      { "<leader>Ap", "<cmd>AvanteProvider<cr>", desc = "Avante Provider" },

      -- History/Session
      { "<leader>Ah", "<cmd>AvanteHistory<cr>", desc = "Avante History" },
      { "<leader>Ax", "<cmd>AvanteClear<cr>", desc = "Avante Clear" },

      -- Review workflow
      { "<leader>Ar", "<cmd>AvanteRefresh<cr>", desc = "Avante Refresh" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "nvim-mini/mini.pick", -- for file_selector provider mini.pick
      "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
      "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
      "ibhagwan/fzf-lua", -- for file_selector provider fzf
      "stevearc/dressing.nvim", -- for input provider dressing
      "folke/snacks.nvim", -- for input provider snacks
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      "zbirenbaum/copilot.lua", -- for providers='copilot'
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  },
}
