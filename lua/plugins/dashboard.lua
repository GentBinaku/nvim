-- Welcome screen (snacks.nvim dashboard), two columns:
--   left:  header, shortcuts, recent files
--   right: git status of the opened folder, recent projects
-- When the window is too narrow for both columns, snacks stacks them into one.

local header = table.concat({
  "███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
  "████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
  "██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
  "██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
  "██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
  "╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
}, "\n")

local function in_git_repo() return Snacks.git.get_root() ~= nil end

local WIDTH, GAP = 56, 6 -- column width and space between the two columns

-- Sections live in a column, so the header would be centred over the left column only.
-- When both columns fit, left-pad it so it's centred across the whole dashboard instead.
local function two_columns(self) return self._size and self._size.width >= 2 * WIDTH + GAP end

local function centered_header(self)
  local lines = vim.split(header, "\n")
  local total = two_columns(self) and 2 * WIDTH + GAP or WIDTH
  local pad = (" "):rep(math.max(0, math.floor((total - vim.fn.strdisplaywidth(lines[1])) / 2)))
  for i, l in ipairs(lines) do lines[i] = pad .. l end
  return { header = table.concat(lines, "\n"), padding = 2 }
end

local function centered_startup(self)
  local item = Snacks.dashboard.sections.startup {}
  if not two_columns(self) then return item end
  local len = 0
  for _, t in ipairs(item.text) do len = len + vim.fn.strdisplaywidth(t[1]) end
  table.insert(item.text, 1, { (" "):rep(math.max(0, math.floor((2 * WIDTH + GAP - len) / 2))) })
  item.align = "left"
  return item
end

---@type LazySpec
return {
  "folke/snacks.nvim",
  opts = function(_, opts)
    opts.dashboard = {
      width = WIDTH,
      formats = { header = { "%s", align = "left" } }, -- centring is done by padding, see centered_header
      pane_gap = GAP,
      preset = {
        header = header,
        keys = {
          { key = "n", icon = " ", desc = "New file", action = ":ene | startinsert" },
          { key = "f", icon = " ", desc = "Find file", action = function() Snacks.picker.files() end },
          { key = "r", icon = " ", desc = "Recent files", action = function() Snacks.picker.recent() end },
          { key = "g", icon = " ", desc = "Find text", action = function() Snacks.picker.grep() end },
          { key = "c", icon = " ", desc = "Config", action = function() Snacks.picker.files { cwd = vim.fn.stdpath "config" } end },
          { key = "s", icon = " ", desc = "Restore session", action = function() require("resession").load "Last Session" end },
          { key = "l", icon = "󰒲 ", desc = "Plugins", action = ":Lazy" },
          { key = "q", icon = " ", desc = "Quit", action = ":qa" },
        },
      },
      sections = {
        -- left column
        centered_header,
        { section = "keys", gap = 1, padding = 2 },
        { icon = " ", title = "Recent files", section = "recent_files", cwd = true, limit = 5, indent = 2, padding = 2 },
        centered_startup,

        -- right column
        { pane = 2, padding = 9 }, -- line up with the shortcuts, below the header
        {
          pane = 2,
          icon = " ",
          title = "Git status",
          section = "terminal",
          enabled = in_git_repo,
          cmd = "git status --short --branch --renames",
          height = 8,
          ttl = 60,
          indent = 2,
          padding = 2,
        },
        { pane = 2, icon = " ", title = "Projects", section = "projects", limit = 5, indent = 2, padding = 2 },
      },
    }
  end,
}
