-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.wrap = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.expandtab = true
vim.opt.showmatch = true
vim.opt.mouse = "a"
vim.opt.incsearch = true
vim.opt.cursorline = true
vim.opt.clipboard = "unnamedplus"
vim.opt.shell = "/bin/zsh"

-- Improve diff experience
vim.opt.diffopt:append("algorithm:patience")
vim.opt.diffopt:append("indent-heuristic")
