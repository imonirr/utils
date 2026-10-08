return {
  "sindrets/diffview.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" }, -- optional, for file icons
  opts = function()
    local actions = require("diffview.actions")

    return {
      keymaps = {
        view = {
          { "n", "<leader>co", false },
          { "n", "<leader>ct", false },
          { "n", "<leader>cb", false },
          { "n", "<leader>ca", false },
          { "n", "<leader>cO", false },
          { "n", "<leader>cT", false },
          { "n", "<leader>cB", false },
          { "n", "<leader>cA", false },
          { "n", "<leader>mo", actions.conflict_choose("ours"), { desc = "Choose ours for conflict" } },
          { "n", "<leader>mt", actions.conflict_choose("theirs"), { desc = "Choose theirs for conflict" } },
          { "n", "<leader>ma", actions.conflict_choose("all"), { desc = "Keep both sides of conflict" } },
          { "n", "<leader>mO", actions.conflict_choose_all("ours"), { desc = "Choose ours for file" } },
          { "n", "<leader>mT", actions.conflict_choose_all("theirs"), { desc = "Choose theirs for file" } },
          { "n", "<leader>mA", actions.conflict_choose_all("all"), { desc = "Keep both sides for file" } },
        },
      },
    }
  end,
}
