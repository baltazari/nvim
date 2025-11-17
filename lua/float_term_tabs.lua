-- ~/.config/nvim/lua/float_term_tabs.lua
-- Floating terminal with auto-renumbered tabs in title bar: [1] 2 3 ...

local M = {}

local state = {
  win = nil, -- floating window id
  bufs = {}, -- array: bufs[1], bufs[2], ...
  current = 1, -- current tab index (1..#bufs)
  max_tabs = 5, -- maximum number of tabs allowed
}

-- Build title like "[1] 2 3"
local function tab_title()
  local parts = {}

  for i, buf in ipairs(state.bufs) do
    if vim.api.nvim_buf_is_valid(buf) then
      if i == state.current then
        table.insert(parts, "[" .. i .. "]")
      else
        table.insert(parts, tostring(i))
      end
    end
  end

  if #parts == 0 then
    return ""
  end

  return table.concat(parts, " ")
end

local function update_title()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    pcall(vim.api.nvim_win_set_config, state.win, {
      title = tab_title(),
      title_pos = "center",
    })
  end
end

local function close_window()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_close(state.win, true)
  end
  state.win = nil
end

local function ensure_window()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    return state.win
  end

  local cols = vim.o.columns
  local lines = vim.o.lines
  local width = math.floor(cols * 0.85)
  local height = math.floor(lines * 0.75)
  if height < 5 then
    height = 5
  end

  local row = math.floor((lines - height) / 2)
  local col = math.floor((cols - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  state.win = vim.api.nvim_open_win(buf, true, {
    style = "minimal",
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    border = "rounded",
    title = tab_title(),
    title_pos = "center",
    noautocmd = true,
  })

  -- ✅ set winhighlight *after* opening the window

  pcall(function()
    vim.api.nvim_set_option_value(
      "winhighlight",
      "NormalFloat:NormalFloat,FloatBorder:FloatBorder,FloatTitle:FloatTitle",
      { win = state.win }
    )
  end)

  -- 'q' closes the float in normal mode
  vim.keymap.set("n", "q", function()
    close_window()
  end, { buffer = buf, nowait = true, silent = true })

  return state.win
end

local function set_term_keymaps(bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr }
  -- ESC: hide the panel (keep tabs alive, like VSCode terminal)
  vim.keymap.set("t", "<Esc>", [[<C-\><C-n>:lua require("float_term_tabs").toggle()<CR>]], opts)
  -- Ctrl+\, Alt+1..5, Alt+] are global keymaps in config/keymaps.lua
end

-- Open tab with given index (1..max_tabs), creating it if needed
function M.open(id)
  id = id or state.current or 1
  if id < 1 then
    id = 1
  end
  if id > state.max_tabs then
    id = state.max_tabs
  end

  local n = #state.bufs
  -- don’t allow skipping numbers; clamp to next possible
  if id > n + 1 then
    id = n + 1
  end
  state.current = id

  local win = ensure_window()

  -- validate win
  if not win or not vim.api.nvim_win_is_valid(win) then
    return
  end

  local buf = state.bufs[id]

  -- create new buffer if needed
  if not buf or not vim.api.nvim_buf_is_valid(buf) then
    buf = vim.api.nvim_create_buf(false, true)
    state.bufs[id] = buf
  end

  -- validate buffer
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end

  -- assign buffer to window safely
  vim.api.nvim_win_set_buf(win, buf)

  -- start shell if buffer is empty
  if vim.api.nvim_buf_line_count(buf) == 1 then
    vim.fn.termopen(vim.o.shell)
  end

  vim.cmd("startinsert")
  set_term_keymaps(buf)
  update_title()

  update_title()
end

-- Toggle the whole floating panel (used by Esc)
function M.toggle()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    close_window()
  else
    if #state.bufs == 0 then
      M.open(1)
    else
      M.open(state.current or 1)
    end
  end
end

-- Close current tab and renumber remaining ones
function M.close_current()
  local n = #state.bufs
  if n == 0 then
    close_window()
    return
  end

  local idx = state.current
  if idx < 1 or idx > n then
    idx = n
  end

  local buf = state.bufs[idx]
  if buf and vim.api.nvim_buf_is_valid(buf) then
    vim.api.nvim_buf_delete(buf, { force = true })
  end

  -- remove this index → all higher tabs shift down
  table.remove(state.bufs, idx)

  local left = #state.bufs
  if left == 0 then
    close_window()
    return
  end

  if idx > left then
    idx = left
  end
  state.current = idx

  M.open(state.current) -- also updates title
end

-- Next tab (1 -> 2 -> ... -> 1) over existing tabs
function M.next()
  local n = #state.bufs
  if n == 0 then
    M.open(1)
    return
  end

  local idx = state.current or 1
  idx = idx + 1
  if idx > n then
    idx = 1
  end
  state.current = idx
  M.open(idx)
end

-- Switch to an existing tab without creating new ones
function M.switch(id)
  local n = #state.bufs
  if n == 0 then
    return -- no tabs yet
  end
  if id < 1 or id > n then
    return -- that tab doesn't exist yet
  end

  state.current = id

  local win = ensure_window()
  local buf = state.bufs[id]
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end

  vim.api.nvim_win_set_buf(win, buf)
  vim.cmd("startinsert")
  set_term_keymaps(buf)
  update_title()
end

-- Create/open a new tab on next index (1..max_tabs)

function M.new_tab()
  -- If panel is closed: just reopen existing tabs (don’t create new)
  if not (state.win and vim.api.nvim_win_is_valid(state.win)) then
    if #state.bufs == 0 then
      -- no tabs yet → open first one
      M.open(1)
    else
      -- tabs exist → reopen current one
      M.open(state.current or 1)
    end
    return
  end

  -- If panel is open: create/open the next tab slot
  local n = #state.bufs
  local id = n + 1
  if id > state.max_tabs then
    id = state.max_tabs
  end

  M.open(id)
end

return M
