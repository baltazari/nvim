-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Close current tab with Alt + W

vim.keymap.set("n", "<A-w>", function()
  -- more than 1 tab? close the tab
  if #vim.api.nvim_list_tabpages() > 1 then
    vim.cmd.tabclose()
    return
  end
  -- more than 1 window in this tab? close the window
  if #vim.api.nvim_tabpage_list_wins(0) > 1 then
    vim.cmd.close()
    return
  end
  -- last window of last tab: make a new empty buffer, then close the old buffer
  local cur = vim.api.nvim_get_current_buf()
  vim.cmd.enew()
  pcall(vim.cmd, "bd " .. cur) -- avoids E89 if buffer already wiped
end, { desc = "Smart close: tab/window/buffer" })
