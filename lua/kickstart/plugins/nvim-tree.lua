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
    }
  end,
}
