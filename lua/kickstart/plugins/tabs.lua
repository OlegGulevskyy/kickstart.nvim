local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

map('n', 'H', '<Cmd>BufferPrevious<CR>', opts)
map('n', 'L', '<Cmd>BufferNext<CR>', opts)
map('n', '<leader>bd', '<Cmd>BufferClose<CR>', opts)

vim.api.nvim_create_autocmd('VimEnter', {
  group = vim.api.nvim_create_augroup('config_custom_highlights', {}),
  callback = function()
    vim.api.nvim_set_hl(0, 'BufferDefaultInactive', { fg = "#aaaaaa" })
  end,
})

return {
  'romgrk/barbar.nvim',
  dependencies = {
    'lewis6991/gitsigns.nvim',     -- OPTIONAL: for git status
    'nvim-tree/nvim-web-devicons', -- OPTIONAL: for file icons
  },
  init = function() vim.g.barbar_auto_setup = false end,
  opts = {
    animation = false,
    highlight_visible = true,
  },
  version = '^1.0.0', -- optional: only update when a new 1.x version is released
}
