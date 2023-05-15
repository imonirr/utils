local api = vim.api
local g = vim.g
local opt = vim.opt

-- Remap leader and local leader to <Space>
api.nvim_set_keymap("", "<Space>", "<Nop>", { noremap = true, silent = true })
g.mapleader = ','
g.maplocalleader = ','

opt.termguicolors = true -- Enable colors in terminal
opt.mouse = "a" --Enable mouse mode
opt.hlsearch = true --Set highlight on search
opt.incsearch = true 
opt.ignorecase = true --Case insensitive searching unless /C or capital in search
-- opt.smartcase = true
-- opt.updatetime = 250 --Decrease update time maybe use 50
opt.backspace = '2'
opt.showcmd = true
opt.laststatus = 2
opt.autowrite = true
opt.cursorline = true
opt.autoread = true

opt.tabstop = 2
opt.shiftwidth = 2
opt.shiftround = true
opt.expandtab = true

opt.number = true --Make line numbers default

opt.swapfile = false
opt.backup = false
opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
opt.undofile = true

opt.clipboard = "unnamedplus" -- Access system clipboard
opt.signcolumn = "yes" -- Always show sign column
opt.scrolloff = 8 


--[[
opt.breakindent = true --Enable break indent
opt.timeoutlen = 300	--	Time in milliseconds to wait for a mapped sequence to complete.

-- Highlight on yank
vim.cmd [[
  augroup YankHighlight
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank()
  augroup end
]]
--]]
