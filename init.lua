-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
-- Make floating windows completely transparent
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none", ctermbg = "none" })
vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none", ctermbg = "none" })
vim.api.nvim_set_hl(0, "FloatTitle", { bg = "none", ctermbg = "none" })
vim.api.nvim_set_hl(0, "Pmenu", { bg = "none", ctermbg = "none" })
vim.api.nvim_set_hl(0, "PmenuSel", { bg = "none", ctermbg = "none" })
