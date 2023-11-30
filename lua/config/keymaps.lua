local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- Move between windows
-- Go left
map("n", "<C-h>", "<C-w>h", opts)
-- Go right
map("n", "<C-l>", "<C-w>l", opts)
-- Go Up
map("n", "<C-k>", "<C-w>k", opts)
-- Go Down
map("n", "<C-j>", "<C-w>j", opts)

-- Save file
map("n", "<C-s>", ":w<CR>", opts)

