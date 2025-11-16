-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
-- then you need to set the option below.
vim.g.lazyvim_picker = "telescope"

-- Disable relative line numbers
vim.opt.relativenumber = false

-- Enable static line numbers
vim.opt.number = true

vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none" })
