-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt
-- local g = vim.g

opt.swapfile = false
opt.fixeol = false

vim.g.maplocalleader = ","

vim.g.snacks_animate = false
-- g.autoformat = true
-- disable lsp log file
-- vim.lsp.set_log_level("off")
-- disable showing diagnostic inline
-- vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
--   virtual_text = false,
-- })

-- disable lsp and jdtls log messages like building jdtls etc on every file change
-- vim.lsp.handlers["language/status"] = function(_, result)
--   -- Print or whatever.
--   return ""
-- end
-- vim.lsp.handlers["$/progress"] = function(_, result, ctx)
--   -- disable progress updates.
--   return false
-- end
--
vim.g.lazyvim_php_lsp = "intelephense"
