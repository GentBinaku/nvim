-- bufferline.nvim: VS Code-style buffer tabs, replacing AstroNvim's heirline tabline

---@type LazySpec
return {
  {
    "akinsho/bufferline.nvim",
    version = "*",
    event = "VeryLazy",
    dependencies = { "echasnovski/mini.icons" },
    opts = {
      options = {
        diagnostics = "coc",
        separator_style = "thin", -- flat VS Code-style tabs
        indicator = { style = "icon", icon = "▎" },
        modified_icon = "●",
        always_show_bufferline = true,
        show_buffer_close_icons = true,
        close_command = function(bufnr) require("astrocore.buffer").close(bufnr) end,
        right_mouse_command = function(bufnr) require("astrocore.buffer").close(bufnr) end,
        offsets = {
          { filetype = "neo-tree", text = "Explorer", highlight = "Directory", separator = true },
        },
      },
    },
  },
  -- drop heirline's tabline so the two don't fight over the top row
  {
    "rebelot/heirline.nvim",
    opts = function(_, opts) opts.tabline = nil end,
  },
  {
    "AstroNvim/astrocore",
    opts = {
      mappings = {
        n = {
          ["]b"] = { "<Cmd>BufferLineCycleNext<CR>", desc = "Next buffer" },
          ["[b"] = { "<Cmd>BufferLineCyclePrev<CR>", desc = "Previous buffer" },
          [">b"] = { "<Cmd>BufferLineMoveNext<CR>", desc = "Move buffer right" },
          ["<b"] = { "<Cmd>BufferLineMovePrev<CR>", desc = "Move buffer left" },
          ["<Leader>bb"] = { "<Cmd>BufferLinePick<CR>", desc = "Pick buffer" },
          ["<Leader>bp"] = { "<Cmd>BufferLineTogglePin<CR>", desc = "Pin buffer" },
        },
      },
    },
  },
}
