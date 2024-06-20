-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- map semicolon to command prompt with colon
vim.keymap.set("n", ";", ":", { desc = "semicolon opens command prompt" })

-- delete save keymap
vim.keymap.del("i", "<c-s>")
vim.keymap.del("x", "<c-s>")
vim.keymap.del("n", "<c-s>")
vim.keymap.del("s", "<c-s>")

-- navigating panes
vim.keymap.set("n", "<C-h", ":wincmd k<CR>")
vim.keymap.set("n", "<C-j", ":wincmd j<CR>")
vim.keymap.set("n", "<C-l", ":wincmd l<CR>")
vim.keymap.set("n", "<C-k", ":wincmd k<CR>")
