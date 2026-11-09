-- coc.nvim: LSP client + completion driven by coc extensions (requires Node.js)
-- Extensions are installed automatically on first start; edit the list below to taste.
-- Per-language settings go in `:CocConfig` (~/.config/nvim/coc-settings.json)

---@type LazySpec
return {
  {
    "neoclide/coc.nvim",
    branch = "release",
    event = { "BufReadPre", "BufNewFile" },
    init = function()
      vim.g.coc_global_extensions = {
        "coc-json",
        "coc-tsserver",
        "coc-pyright",
        "coc-lua",
        "coc-clangd", -- C/C++, uses system clangd
        "coc-cmake", -- needs `cmake-language-server` on PATH
        "coc-rust-analyzer", -- uses rustup's rust-analyzer component
        "coc-java", -- downloads jdtls itself; needs a JDK 21+ (from mise)
        "coc-docker",
        "coc-yaml",
        "coc-toml",
        "coc-sh", -- install `shellcheck` for lint diagnostics
        "coc-snippets",
        "coc-prettier",
      }
    end,
    config = function()
      local map = vim.keymap.set
      local opts = { silent = true, nowait = true }

      -- completion: <Tab>/<S-Tab> navigate, <CR> confirms
      local function check_backspace()
        local col = vim.fn.col "." - 1
        return col == 0 or vim.fn.getline("."):sub(col, col):match "%s" ~= nil
      end
      _G.coc_check_backspace = check_backspace
      local expr = { silent = true, noremap = true, expr = true, replace_keycodes = false }
      map(
        "i",
        "<Tab>",
        'coc#pum#visible() ? coc#pum#next(1) : v:lua.coc_check_backspace() ? "<Tab>" : coc#refresh()',
        expr
      )
      map("i", "<S-Tab>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], expr)
      map("i", "<CR>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], expr)
      map("i", "<C-Space>", "coc#refresh()", { silent = true, expr = true })
      -- arrows and <C-j>/<C-k> also move through the list
      map("i", "<Down>", [[coc#pum#visible() ? coc#pum#next(1) : "\<Down>"]], expr)
      map("i", "<Up>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<Up>"]], expr)
      map("i", "<C-j>", [[coc#pum#visible() ? coc#pum#next(1) : "\<C-j>"]], expr)
      map("i", "<C-k>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-k>"]], expr)
      map("i", "<Esc>", [[coc#pum#visible() ? coc#pum#cancel() : "\<Esc>"]], expr)

      -- navigation
      map("n", "gd", "<Plug>(coc-definition)", vim.tbl_extend("force", opts, { desc = "Go to definition" }))
      map("n", "gy", "<Plug>(coc-type-definition)", vim.tbl_extend("force", opts, { desc = "Go to type definition" }))
      map("n", "gi", "<Plug>(coc-implementation)", vim.tbl_extend("force", opts, { desc = "Go to implementation" }))

      -- find usages
      map("n", "gr", "<Plug>(coc-references)", vim.tbl_extend("force", opts, { desc = "Find usages" }))
      map("n", "<Leader>lu", "<Plug>(coc-references-used)", vim.tbl_extend("force", opts, { desc = "Find usages (excl. declaration)" }))

      -- diagnostics
      map("n", "[d", "<Plug>(coc-diagnostic-prev)", vim.tbl_extend("force", opts, { desc = "Previous diagnostic" }))
      map("n", "]d", "<Plug>(coc-diagnostic-next)", vim.tbl_extend("force", opts, { desc = "Next diagnostic" }))
      map("n", "<Leader>lD", ":<C-u>CocList diagnostics<CR>", vim.tbl_extend("force", opts, { desc = "List diagnostics" }))

      -- hover docs
      map("n", "K", function()
        if vim.fn.CocAction("hasProvider", "hover") then
          vim.fn.CocActionAsync "doHover"
        else
          vim.api.nvim_feedkeys("K", "in", false)
        end
      end, vim.tbl_extend("force", opts, { desc = "Hover documentation" }))

      -- refactoring
      map("n", "<Leader>lr", "<Plug>(coc-rename)", vim.tbl_extend("force", opts, { desc = "Rename symbol" }))
      map({ "n", "x" }, "<Leader>la", "<Plug>(coc-codeaction-cursor)", vim.tbl_extend("force", opts, { desc = "Code action" }))
      map({ "n", "x" }, "<Leader>lf", "<Plug>(coc-format-selected)", vim.tbl_extend("force", opts, { desc = "Format" }))
      map("n", "<Leader>ls", ":<C-u>CocList -I symbols<CR>", vim.tbl_extend("force", opts, { desc = "Workspace symbols" }))

      -- highlight symbol under cursor on hold
      vim.api.nvim_create_autocmd("CursorHold", {
        group = vim.api.nvim_create_augroup("CocHighlight", {}),
        command = "silent call CocActionAsync('highlight')",
        desc = "Highlight symbol under cursor",
      })
    end,
  },
  -- coc is the completion engine; disable AstroNvim's blink.cmp so two popups don't stack
  { "saghen/blink.cmp", enabled = false },
  { "saghen/blink.compat", enabled = false },
  { "rcarriga/cmp-dap", enabled = false },
  -- coc runs the language servers; turn off AstroNvim's native LSP stack so files don't get two of each
  -- (duplicate diagnostics, double popups, formatting twice). mason stays for nvim-dap's debuggers.
  { "neovim/nvim-lspconfig", enabled = false },
  { "mason-org/mason-lspconfig.nvim", enabled = false },
  { "nvimtools/none-ls.nvim", enabled = false },
  { "jay-babu/mason-null-ls.nvim", enabled = false },
  { "WhoIsSethDaniel/mason-tool-installer.nvim", enabled = false },
  -- no auto-inserted closing brackets/quotes
  { "windwp/nvim-autopairs", enabled = false },
  -- hardtime blocks arrow keys in insert mode by default; allow them there
  {
    "m4xshen/hardtime.nvim",
    optional = true,
    opts = {
      disabled_keys = {
        ["<Up>"] = { "n", "x" },
        ["<Down>"] = { "n", "x" },
        ["<Left>"] = { "n", "x" },
        ["<Right>"] = { "n", "x" },
      },
    },
  },
  {
    "AstroNvim/astrocore",
    opts = {
      options = {
        opt = {
          pumheight = 8, -- cap the suggestion list at 8 rows (+2 border fits in the 10 lines of scrolloff)
        },
      },
      -- turn off AstroNvim's built-in completion popup so it doesn't fight coc's
      features = { cmp = false },
      mappings = {
        n = {
          -- <Leader>fu is "Find usages"; undo history moves to <Leader>fU
          ["<Leader>fu"] = { function() vim.fn.CocActionAsync "jumpReferences" end, desc = "Find usages" },
          ["<Leader>fU"] = { function() require("snacks").picker.undo() end, desc = "Find undo history" },
        },
      },
    },
  },
}
