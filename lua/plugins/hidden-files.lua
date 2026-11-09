-- Show dotfiles (.clang-format, .github, .env, ...) by default in the explorer and pickers.
-- Git-ignored files (build/, vcpkg_installed/) also show in neo-tree, dimmed; `H` toggles hidden items.

---@type LazySpec
return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
          never_show = { ".git" },
        },
      },
    },
  },
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          files = { hidden = true, exclude = { ".git" } },
          grep = { hidden = true, exclude = { ".git" } },
        },
      },
    },
  },
}
