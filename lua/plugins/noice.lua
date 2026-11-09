-- noice.nvim: floating command line and search popups, messages as notifications.
-- The command line no longer needs its own row, so the status bar sits on the last line.
-- coc handles LSP here, so noice's LSP features are turned off to avoid clashing with it.

---@type LazySpec
return {
  {
    "folke/noice.nvim",
    opts = {
      lsp = {
        progress = { enabled = false },
        hover = { enabled = false },
        signature = { enabled = false },
        message = { enabled = false },
        override = {},
      },
      presets = {
        bottom_search = false, -- `/` and `?` get a popup too
        command_palette = true, -- command line and its completion menu sit together near the top
        long_message_to_split = true, -- long output (e.g. :messages) opens in a split
      },
      routes = {
        -- hide "written" / "lines yanked"-style chatter
        { filter = { event = "msg_show", any = { { find = "%d+L, %d+B" }, { find = "; after #%d+" }, { find = "; before #%d+" } } }, opts = { skip = true } },
      },
    },
  },
  {
    "AstroNvim/astrocore",
    opts = {
      options = {
        opt = {
          cmdheight = 0,
          -- command suggestions: list pops up as you type, nothing is picked until you press <Tab>/arrows
          wildmode = "noselect:lastused,full",
          wildoptions = "pum,fuzzy", -- fuzzy: `:lzy` still finds `:Lazy`
        },
      },
      autocmds = {
        cmdline_suggestions = {
          {
            event = "CmdlineChanged",
            pattern = ":",
            desc = "Suggest commands while typing",
            callback = function() vim.fn.wildtrigger() end,
          },
        },
      },
      mappings = {
        c = {
          -- <Up>/<Down> still walk command history when you haven't opened the list with <Tab>
          ["<Up>"] = { function() return vim.fn.wildmenumode() == 1 and "<C-E><Up>" or "<Up>" end, expr = true },
          ["<Down>"] = { function() return vim.fn.wildmenumode() == 1 and "<C-E><Down>" or "<Down>" end, expr = true },
        },
      },
    },
  },
}
