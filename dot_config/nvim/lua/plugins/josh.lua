return {
  -- Time tracking, carried over from vim-wakatime. Reads ~/.wakatime.cfg.
  { "wakatime/vim-wakatime", event = "VeryLazy" },

  { "LazyVim/LazyVim", opts = { colorscheme = "tokyonight-night" } },

  -- The old config opened definitions in a vertical split. LazyVim's LSP
  -- keymaps are buffer-local, so `gd` has to be replaced in its own list
  -- rather than shadowed by a global map. Splitting first and then jumping
  -- works whichever picker LazyVim is configured with.
  {
    "neovim/nvim-lspconfig",
    opts = function()
      local keys = require("lazyvim.plugins.lsp.keymaps").get()
      keys[#keys + 1] = {
        "gd",
        function()
          vim.cmd("vsplit")
          vim.lsp.buf.definition()
        end,
        desc = "Goto Definition (vsplit)",
        has = "definition",
      }
    end,
  },
}
