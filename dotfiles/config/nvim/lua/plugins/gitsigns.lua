return {
  "lewis6991/gitsigns.nvim",
  opts = function(_, opts)
    -- Extend Gitsigns' built-in keymapping setup function (on_attach)
    local user_on_attach = opts.on_attach

    opts.on_attach = function(bufnr)
      -- Preserve any existing default LazyVim gitsigns keymaps
      if user_on_attach then
        user_on_attach(bufnr)
      end

      local gs = require("gitsigns")
      local map = vim.keymap.set

      -- Buffer-local keymap to toggle git base branch (main <-> HEAD)
      map("n", "<leader>gR", function()
        local current_base = vim.b[bufnr].gitsigns_base or "HEAD"
        local new_base = (current_base == "main") and "HEAD" or "main"

        gs.change_base(new_base, true)
        vim.notify("Gitsigns base changed to: " .. new_base, vim.log.levels.INFO)
      end, { buffer = bufnr, desc = "Toggle Git Diff Base (HEAD / main)" })
    end
  end,
}
