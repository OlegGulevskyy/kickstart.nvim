-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true

local function toggle_nvim_tree_view()
  local nvim_tree_api = require "nvim-tree.api"
  local opts = {
    find_file = true
  }
  nvim_tree_api.tree.toggle(opts)
end

vim.keymap.set('n', '<leader>e', toggle_nvim_tree_view, { desc = "Open file tree view" })
vim.keymap.set('n', '<leader>z', "<cmd>NvimTreeCollapse<CR>", { desc = "Collapse file tree view" })

local function my_on_attach(bufnr)
  local api = require('nvim-tree.api')
  local function opts(desc)
    return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  -- copy default mappings here from defaults in next section
  vim.keymap.set('n', '<C-]>', api.tree.change_root_to_node,          opts('CD'))
  vim.keymap.set('n', '<C-e>', api.node.open.replace_tree_buffer,     opts('Open: In Place'))
  vim.keymap.set('n', 'l', api.node.open.tab,     opts('Open: In New Tab'))
  vim.keymap.set('n', 'h', api.node.navigate.parent_close,     opts('Close'))
  ---
  -- OR use all default mappings
  api.config.mappings.default_on_attach(bufnr)

  -- remove a default
  vim.keymap.del('n', '<C-]>', { buffer = bufnr })

  -- override a default
  vim.keymap.set('n', '<C-r>', api.tree.reload,                       opts('Refresh'))

  -- add your mappings
  vim.keymap.set('n', '?',     api.tree.toggle_help,                  opts('Help'))
  ---
end

local function openNvimConfig()
  -- Open the init.lua file
  vim.cmd('edit ~/.config/nvim/init.lua')

  -- Change nvim-tree's root to the config directory
  -- Not working currently
  require'nvim-tree.lib'.change_dir('~/.config/nvim')
end

-- Map the function to a keybinding
vim.api.nvim_set_keymap('n', '<leader>ne', ':lua openNvimConfig()<CR>', { noremap = true, silent = true })

return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local nvtree = require("nvim-tree")
    nvtree.setup {
      view = {
        width = 30,
        adaptive_size = false,
      },
      on_attach = my_on_attach,
    }
  end,
}
