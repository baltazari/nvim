-- ~/.config/nvim/lua/config/error_float.lua
-- Show Vim/Neovim errors (like E5108) in a floating window that stays until Esc/q.

local M = {}

local function open_error_float(msg)
  if not msg or msg == "" then
    return
  end

  -- Split message into lines
  local lines = vim.split(msg, "\n", { plain = true })

  local cols = vim.o.columns
  local lines_total = vim.o.lines

  local width = math.floor(cols * 0.7)
  local height = math.min(#lines + 2, math.floor(lines_total * 0.5))

  local row = math.floor((lines_total - height) / 2)
  local col = math.floor((cols - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  local win = vim.api.nvim_open_win(buf, true, {
    style = "minimal",
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    border = "rounded",
    title = " Error ",
    title_pos = "center",
  })

  -- Use float highlights (transparent if you set them)
  pcall(
    vim.api.nvim_set_option_value,
    "winhighlight",
    "NormalFloat:NormalFloat,FloatBorder:FloatBorder,FloatTitle:FloatTitle",
    { win = win }
  )

  -- q or Esc closes the error window
  local opts = { noremap = true, silent = true, buffer = buf }
  vim.keymap.set("n", "q", function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end, opts)
  vim.keymap.set("n", "<Esc>", function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end, opts)
end

-- Autocmd to show last error in float after a command errors
vim.api.nvim_create_autocmd("CmdlineLeave", {
  callback = function()
    local err = vim.v.errmsg
    if err ~= nil and err ~= "" then
      -- Clear it so we don't reopen for the same error
      vim.v.errmsg = ""
      open_error_float(err)
    end
  end,
})

return M
