-- VS Code look: explorer docked on the left, sticky scroll, scrollbar with marks,
-- absolute line numbers and a highlighted current line.

---@type LazySpec
return {
  -- Explorer on the left, like VS Code's side bar (toggle with <Leader>e; no longer opens at startup)
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      window = { width = 32 },
      default_component_configs = {
        indent = { with_expanders = true, expander_collapsed = "", expander_expanded = "" },
        git_status = { symbols = { added = "A", modified = "M", deleted = "D", renamed = "R", untracked = "U", ignored = "", unstaged = "", staged = "", conflict = "!" } },
      },
      filesystem = { follow_current_file = { enabled = true } },
    },
  },

  -- Sticky scroll: keep the current function/class header pinned at the top
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    opts = { max_lines = 4, multiline_threshold = 1, separator = nil },
  },

  -- Scrollbar with git/search/diagnostic marks, like VS Code's overview ruler
  {
    "lewis6991/satellite.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      excluded_filetypes = { "neo-tree", "snacks_dashboard", "lazy", "mason", "toggleterm" },
    },
  },

  -- Editor options
  {
    "AstroNvim/astrocore",
    opts = {
      options = {
        opt = {
          relativenumber = true, -- current line shows its number, others show distance
          number = true,
          cursorline = true,
          signcolumn = "yes",
          scrolloff = 10, -- keep 10 lines below the cursor so the suggestion list fits underneath it
          wrap = false,
          mouse = "a",
          fillchars = { eob = " " }, -- hide ~ on empty lines
        },
      },
      autocmds = {
        -- 'scrolloff' stops working at the end of a file (Vim won't scroll past the last line),
        -- so the cursor can still reach the bottom row and the suggestion list flips up over the code.
        -- Scroll the view so there are always 'scrolloff' rows below the cursor, even past the end.
        scroll_past_eof = {
          {
            event = { "CursorMoved", "CursorMovedI" },
            desc = "Keep scrolloff rows below the cursor at the end of the file",
            callback = function()
              local win = vim.api.nvim_get_current_win()
              if vim.api.nvim_win_get_config(win).relative ~= "" or vim.bo.buftype ~= "" then return end
              local so = vim.wo.scrolloff
              if vim.fn.line "$" - vim.fn.line "." >= so then return end -- normal scrolloff handles it
              local missing = so - (vim.api.nvim_win_get_height(win) - vim.fn.winline())
              if missing > 0 then
                local view = vim.fn.winsaveview()
                view.topline = view.topline + missing
                vim.fn.winrestview(view)
              end
            end,
          },
        },
      },
    },
  },
}
