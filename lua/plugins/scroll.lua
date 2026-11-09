-- Smooth scrolling via neoscroll.nvim
-- Animates <C-u>/<C-d>/<C-b>/<C-f>/<C-y>/<C-e> and zt/zz/zb

---@type LazySpec
return {
  {
    "karb94/neoscroll.nvim",
    event = "VeryLazy",
    opts = {
      duration_multiplier = 1.0, -- raise to slow every animation down, lower to speed it up
      easing = "quadratic",
      hide_cursor = true,
      stop_eof = true, -- stop <C-d>/<C-f> at the end of the file
    },
  },
  -- keep snacks' own smooth scroll off so the two don't animate the same keys
  {
    "folke/snacks.nvim",
    opts = { scroll = { enabled = false } },
  },
}
