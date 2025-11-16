-- Using Lazy
-- return {
--   "navarasu/onedark.nvim",
--   priority = 1000, -- make sure to load this before all the other start plugins
--   config = function()
--     require("onedark").setup({
--       style = "cool",
--     })
--     require("onedark").load()
--   end,
-- }

return {
  {
    "olimorris/onedarkpro.nvim",
    priority = 1000, -- load first
    config = function()
      vim.cmd("colorscheme onedark") -- or onedark_vivid, onelight, etc.
    end,
  },
}
