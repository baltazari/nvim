-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
-- Force visible colors for completion / popup menus
-- Make sure no global winhighlight breaks popups / menus
vim.opt.winhighlight = ""
local function fix_menu_highlights()
  -- dropdown background
  vim.api.nvim_set_hl(0, "Pmenu", { fg = "#c0caf5" })
  -- selected item
  vim.api.nvim_set_hl(0, "PmenuSel", { bg = "#3b4261", fg = "#ffffff" })

  -- some completion plugins use these:
  vim.api.nvim_set_hl(0, "CmpItemAbbr", { fg = "#c0caf5" })
  vim.api.nvim_set_hl(0, "CmpItemAbbrMatch", { fg = "#7aa2f7", bold = true })
  vim.api.nvim_set_hl(0, "CmpItemSel", { bg = "#3b4261", fg = "#ffffff" })
end

-- run once on startup
fix_menu_highlights()

-- run again after colorscheme changes (LazyVim changes theme dynamically)
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = fix_menu_highlights,
})
