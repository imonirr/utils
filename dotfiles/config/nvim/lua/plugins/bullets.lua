return {
  "dkarter/bullets.vim",
  ft = { "markdown", "text" },
  config = function()
    -- This ensures it doesn't conflict with other Enter mappings
    vim.g.bullets_enabled_filetypes = { "markdown", "text" }
    vim.g.bullets_set_mappings = 1

    -- This makes it so hitting enter in a [ ] item creates a new [ ] item
    vim.g.bullets_checkbox_markers = " "
  end,
}
