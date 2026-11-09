-- Follow the current Omarchy theme.
-- Every Omarchy theme ships a LazyVim-style neovim.lua (plugin spec + colorscheme name);
-- we load its plugins here and hand the colorscheme to AstroUI. `omarchy theme set`
-- is picked up live by watching ~/.local/state/omarchy/current.

local state_dir = vim.fn.expand "~/.local/state/omarchy/current"
local fallback = "tokyonight-night" -- for Omarchy themes without a neovim.lua

-- returns the theme's plugin specs and colorscheme name
local function read_omarchy_theme()
  local ok, spec = pcall(dofile, state_dir .. "/theme/neovim.lua")
  if not ok or type(spec) ~= "table" then return {}, fallback end

  local plugins, colorscheme = {}, fallback
  for _, plugin in ipairs(spec) do
    if plugin[1] == "LazyVim/LazyVim" then
      colorscheme = vim.tbl_get(plugin, "opts", "colorscheme") or colorscheme
    else
      table.insert(plugins, plugin)
    end
  end
  return plugins, colorscheme
end

local function watch_omarchy_theme()
  local handle = vim.uv.new_fs_event()
  if not handle then return end
  local timer = vim.uv.new_timer()
  handle:start(state_dir, {}, function()
    -- theme-set rewrites several files; react once it has settled
    timer:start(300, 0, vim.schedule_wrap(function()
      local _, colorscheme = read_omarchy_theme()
      if colorscheme == vim.g.colors_name then return end
      if not pcall(vim.cmd.colorscheme, colorscheme) then
        vim.notify(
          ("Omarchy theme changed to %s; restart Neovim to install its colorscheme"):format(colorscheme),
          vim.log.levels.INFO
        )
      end
    end))
  end)
end

-- VS Code look: use vscode.nvim (Dark Modern) instead of following Omarchy.
-- Set to true to go back to syncing with `omarchy theme set`.
local follow_omarchy = false

if not follow_omarchy then
  ---@type LazySpec
  return {
    {
      "Mofiqul/vscode.nvim",
      lazy = false,
      priority = 1000,
      opts = {
        style = "dark",
        italic_comments = true,
        underline_links = true,
        disable_nvimtree_bg = true,
      },
    },
    { "AstroNvim/astroui", opts = { colorscheme = "vscode" } },
  }
end

local plugins, colorscheme = read_omarchy_theme()

---@type LazySpec
return vim.list_extend(plugins, {
  { "folke/tokyonight.nvim", lazy = true },
  {
    "AstroNvim/astroui",
    opts = { colorscheme = colorscheme },
    init = watch_omarchy_theme,
  },
})
