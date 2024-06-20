return {
  "vim-test/vim-test",
  enabled = false,
  vim.keymap.set("n", "<leader>t", ":TestNearest<CR>"),
  vim.keymap.set("n", "<leader>T", ":TestFile<CR>"),
}
