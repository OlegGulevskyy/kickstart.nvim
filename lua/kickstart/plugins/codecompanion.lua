return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "nvim-telescope/telescope.nvim", -- Optional
    {
      "stevearc/dressing.nvim",      -- Optional: Improves the default Neovim UI
      opts = {},
    },
  },
  config = function()
    require("codecompanion").setup({
      strategies = { chat = { adapter = "openai" } },
      adapters = {
        openai = function()
          return require("codecompanion.adapters").extend("openai", {
            schema = {
              model = {
                default = "gpt-4o"
              },
            },
          })
        end,
      },
    })
  end
}
