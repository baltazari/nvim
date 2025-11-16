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

-- Ctrl+/ → always create/open the next tab (1..5)
vim.keymap.set({ "n", "t", "i" }, "<C-`>", function()
  require("float_term_tabs").new_tab()
end, { desc = "New floating terminal tab" })

-- Ctrl+\ → close current terminal tab and renumber
vim.keymap.set({ "n", "t", "i" }, "<C-\\>", function()
  require("float_term_tabs").close_current()
end, { desc = "Close current terminal tab" })

-- Alt+1..5 → ONLY switch to existing tabs (no creation)
vim.keymap.set({ "n", "t", "i" }, "<A-1>", function()
  require("float_term_tabs").switch(1)
end, { desc = "Switch to terminal tab 1" })

vim.keymap.set({ "n", "t", "i" }, "<A-2>", function()
  require("float_term_tabs").switch(2)
end, { desc = "Switch to terminal tab 2" })

vim.keymap.set({ "n", "t", "i" }, "<A-3>", function()
  require("float_term_tabs").switch(3)
end, { desc = "Switch to terminal tab 3" })

vim.keymap.set({ "n", "t", "i" }, "<A-4>", function()
  require("float_term_tabs").switch(4)
end, { desc = "Switch to terminal tab 6" })

vim.keymap.set({ "n", "t", "i" }, "<A-5>", function()
  require("float_term_tabs").switch(5)
end, { desc = "Switch to terminal tab 5" })

-- Alt+] → next tab (cycle through existing)
vim.keymap.set({ "n", "t", "i" }, "<A-tab>", function()
  require("float_term_tabs").next()
end, { desc = "Next terminal tab" })
