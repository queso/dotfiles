-- Loaded on VeryLazy, after LazyVim's own keymaps.
-- LazyVim defaults: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

local map = vim.keymap.set

-- <Space> is not the leader here, so it keeps its old job.
map("n", "<Space>", "<cmd>set hlsearch!<cr>", { desc = "Toggle hlsearch" })

-- No arrow keys.
for _, key in ipairs({ "<Up>", "<Down>", "<Left>", "<Right>" }) do
  map({ "n", "v" }, key, "<nop>")
end

-- Strip trailing whitespace and retab, keeping the search register.
map("n", "<leader>rw", function()
  local save = vim.fn.getreg("/")
  local view = vim.fn.winsaveview()
  vim.cmd([[keeppatterns %s/\s\+$//e]])
  vim.cmd("retab")
  vim.fn.setreg("/", save)
  vim.fn.winrestview(view)
end, { desc = "Strip trailing whitespace" })

-- Old fzf.vim bindings, pointed at LazyVim's picker.
map("n", "<C-p>", function()
  LazyVim.pick("git_files")()
end, { desc = "Find Files (git)" })
map("n", "<leader>l", function()
  LazyVim.pick("buffers")()
end, { desc = "Buffers" })

-- can haz spell
vim.cmd([[
  iabbrev inpsection inspection
  iabbrev Inpsection Inspection
]])
