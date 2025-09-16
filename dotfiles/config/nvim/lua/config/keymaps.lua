-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local java_utils = require("utils.java")

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

vim.keymap.set("n", "<leader>jr", function()
  java_utils.run_spring_boot()
end, { desc = "Run:SpringBoot" })

vim.keymap.set("n", "<leader>jd", function()
  java_utils.run_spring_boot(true)
end, { desc = "DEBUG:SpringBoot" })

vim.keymap.set("n", "<leader>jtm", function()
  java_utils.run_java_test_method()
end, { desc = "TestMethod:SpringBoot" })

vim.keymap.set("n", "<leader>jtM", function()
  java_utils.run_java_test_method(true)
end, { desc = "DebugTestMethod:SpringBoot" })

vim.keymap.set("n", "<leader>jtc", function()
  java_utils.run_java_test_class()
end, { desc = "TestClass:SpringBoot" })

vim.keymap.set("n", "<leader>jtC", function()
  java_utils.run_java_test_class(true)
end, { desc = "DebugTestClass:SpringBoot" })

-- custom intellij formatter for java
vim.keymap.set("n", "<leader>fj", function()
  require("conform").format({
    async = true,
    lsp_fallback = false,
    formatters = { "intellij_java_formatter" },
    -- formatters = { "spotless" },
  })
end, { desc = "Format Java with IntelliJ" })
