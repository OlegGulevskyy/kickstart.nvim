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
      strategies = { chat = { adapter = "anthropic" } },
      adapters = {
        anthropic = function()
          return require("codecompanion.adapters").extend("anthropic", {
            env = {
              api_key =
              "cmd:op item get sfhj2i44a352itn6fvfn3awydu --reveal --field credential"
            },
            schema = {
              model = {
                default = "claude-3-5-sonnet-20241022"
              },
            },
          })
        end,
      },
    })
  end
}
