-- lualine: status line at the bottom, replacing AstroNvim's heirline statusline
-- Styled flat like the VS Code status bar, with colors from vscode.nvim

-- coc's language server progress/status text, e.g. "clangd: indexing 12/40"
local function coc_status()
  local status = vim.g.coc_status or ""
  return status:gsub("%%", "%%%%")
end

-- VS Code-style "Spaces: 2" / "Tab Size: 4"
local function indentation()
  if vim.bo.expandtab then return "Spaces: " .. vim.fn.shiftwidth() end
  return "Tab Size: " .. vim.bo.tabstop
end

-- "recording @q" while a macro is being recorded
local function macro_recording()
  local reg = vim.fn.reg_recording()
  return reg == "" and "" or ("recording @" .. reg)
end

-- names of the coc language servers running for this filetype, e.g. "clangd".
-- Asking coc is a blocking call, so it's cached and only refreshed on buffer/coc events.
local lsp_names = ""
local function refresh_lsp_names()
  if vim.g.coc_service_initialized ~= 1 then return end
  local ok, services = pcall(vim.fn.CocAction, "services")
  if not ok or type(services) ~= "table" then return end
  local ft, names = vim.bo.filetype, {}
  for _, svc in ipairs(services) do
    if svc.state == "running" and vim.tbl_contains(svc.languageIds or {}, ft) then
      table.insert(names, (svc.id:gsub("^languageserver%.", "")))
    end
  end
  lsp_names = table.concat(names, ", ")
end
local function lsp_clients() return lsp_names == "" and "" or (" " .. lsp_names) end

-- half-circle glyphs (Nerd Font) that round off the ends of the mode and position blocks
local PILL_L, PILL_R = "\u{e0b6}", "\u{e0b4}"

-- true in normal file windows; false on the dashboard, explorer, terminal and other special windows,
-- so the bar keeps the same look everywhere but only shows file details where they make sense
local function is_file() return vim.bo.buftype == "" and vim.bo.filetype ~= "snacks_dashboard" end

---@type LazySpec
return {
  -- tracks Neovim coding time and adds its own "today" total to lualine_x
  { "wakatime/vim-wakatime", lazy = false },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "echasnovski/mini.icons" },
    init = function()
      local group = vim.api.nvim_create_augroup("LualineExtras", {})
      vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
        group = group,
        callback = refresh_lsp_names,
        desc = "Update language server name in status line",
      })
      vim.api.nvim_create_autocmd("User", {
        group = group,
        pattern = { "CocNvimInit", "CocStatusChange" },
        callback = refresh_lsp_names,
        desc = "Update language server name in status line",
      })
      -- redraw immediately when a macro starts/stops instead of waiting for the next refresh
      vim.api.nvim_create_autocmd({ "RecordingEnter", "RecordingLeave" }, {
        group = group,
        callback = function() vim.schedule(function() require("lualine").refresh() end) end,
        desc = "Show macro recording in status line",
      })
    end,
    opts = {
      options = {
        -- follow the colorscheme, but let the middle of the bar show the editor background
        theme = function()
          local theme = require("lualine.utils.loader").load_theme "auto"
          for _, mode in pairs(theme) do
            for _, section in ipairs { "b", "c", "x", "y" } do
              if mode[section] then mode[section].bg = "None" end
            end
          end
          return theme
        end,
        globalstatus = true,
        component_separators = "",
        section_separators = "",
      },
      sections = {
        -- rounded "pill" on the left
        lualine_a = { { "mode", separator = { left = PILL_L, right = PILL_R }, padding = 1 } },
        lualine_b = {
          { "branch", icon = "\u{e725}", padding = { left = 2, right = 1 } },
          { "diff", symbols = { added = "+", modified = "~", removed = "-" } },
        },
        lualine_c = {
          { macro_recording, color = "WarningMsg" },
          {
            "filename",
            cond = is_file,
            path = 1,
            padding = { left = 2, right = 1 },
            symbols = { modified = "\u{25cf}", readonly = "\u{f023}", unnamed = "[No Name]" },
          },
        },
        lualine_x = {
          { coc_status, color = "Comment" },
          {
            "diagnostics",
            sources = { "coc" },
            symbols = { error = "\u{f057} ", warn = "\u{f071} ", info = "\u{f05a} ", hint = "\u{f0eb} " },
          },
          { "searchcount", maxcount = 999 },
          { "selectioncount" },
          { lsp_clients, color = "Comment", cond = function() return lsp_names ~= vim.bo.filetype end },
          -- only worth showing when it's unusual
          { "encoding", cond = function() return vim.bo.fileencoding ~= "" and vim.bo.fileencoding ~= "utf-8" end },
          { "fileformat", cond = is_file, symbols = { unix = "", dos = "CRLF", mac = "CR" } },
          { "filetype", cond = is_file, padding = { left = 1, right = 2 } },
        },
        lualine_y = {},
        -- rounded "pill" on the right
        lualine_z = {
          {
            function() return ("%d:%d"):format(vim.fn.line ".", vim.fn.virtcol ".") end,
            cond = is_file,
            separator = { left = PILL_L, right = PILL_R },
            padding = 1,
          },
        },
      },
      -- no extensions: the same bar shows in every window (dashboard, explorer, terminal, ...)
    },
  },
  -- drop heirline's statusline so lualine owns the bottom row
  {
    "rebelot/heirline.nvim",
    opts = function(_, opts) opts.statusline = nil end,
  },
}
