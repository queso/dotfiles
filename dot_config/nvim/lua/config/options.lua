-- Loaded before lazy.nvim starts, after LazyVim's own defaults.
-- LazyVim defaults: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

-- Leader stays where twenty years of fingers expect it. LazyVim's docs and
-- videos all say <Space>; here that is backslash. <Space> toggles hlsearch
-- (see keymaps.lua), so localleader moves off backslash to avoid the clash.
vim.g.mapleader = "\\"
vim.g.maplocalleader = ","

-- Ported from .vimrc
vim.opt.relativenumber = false -- the old config was plain `set nu`
vim.opt.timeoutlen = 250
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.colorcolumn = "81"
