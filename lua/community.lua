-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.pack.lua" },
  -- { import = "astrocommunity.workflow.bad-practices-nvim" }, -- replaced by hardtime (same hints, no command-line noise)
  { import = "astrocommunity.workflow.hardtime-nvim" },
  { import = "astrocommunity.workflow.precognition-nvim" },
  { import = "astrocommunity.recipes.vscode" },
  { import = "astrocommunity.motion.flash-nvim" }, -- s + two letters: jump anywhere on screen
  { import = "astrocommunity.motion.mini-surround" },
  { import = "astrocommunity.utility.noice-nvim" }, -- popup command line + notification-style messages -- add/change/delete surrounding quotes and brackets
  -- import/override with your plugins folder
}
