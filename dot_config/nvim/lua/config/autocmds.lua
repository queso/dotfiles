-- Loaded on VeryLazy, after LazyVim's own autocmds.
-- LazyVim defaults: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Remove a default group with e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local augroup = vim.api.nvim_create_augroup("josh", { clear = true })

-- Trailing whitespace stays visible, as `match ErrorMsg '\s\+$'` did.
vim.api.nvim_create_autocmd({ "BufWinEnter", "WinNew" }, {
  group = augroup,
  callback = function()
    if vim.bo.buftype ~= "" then
      return
    end
    for _, m in ipairs(vim.fn.getmatches()) do
      if m.group == "ErrorMsg" then
        return
      end
    end
    vim.fn.matchadd("ErrorMsg", [[\s\+$]])
  end,
})

-- Filetypes neovim does not guess on its own.
vim.filetype.add({
  pattern = {
    [".*%.handlebars%..*"] = "handlebars",
    ["Jimfile"] = "javascript",
  },
})
