-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local Util = require("lazyvim.util")

local java_utils = require("utils.java")
local kuala_utils = require("utils.kuala")

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
vim.keymap.set("n", "<leader>cj", function()
  require("conform").format({
    async = true,
    lsp_fallback = false,
    formatters = { "intellij_java_formatter" },
    -- formatters = { "spotless" },
  })
end, { desc = "Format Java with IntelliJ" })

-- preview kuala response
vim.keymap.set("n", "<leader>kr", function()
  kuala_utils.open_kulala_response()
end, { desc = "Kulala: Preview large response" })

-- Create pull request on azure devops
vim.keymap.set("n", "<leader>pc", function()
  Util.terminal({ "pr-create" }, {
    cwd = Util.root(),
    direction = "horizontal",
  })
end, { desc = "Create Azure DevOps PR" })

-- Create pr description with github copilot
-- vim.keymap.set("n", "<leader>gd", function()
--   require("utils.copilot_pr").generate_pr_description()
-- end, { desc = "Generate PR description with Copilot" })
vim.keymap.set("n", "<leader>pd", function()
  require("utils.pr_description").generate()
end, { desc = "Generate PR description (Copilot)" })
