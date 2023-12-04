return {
  'mhartington/formatter.nvim',
  config = function()
    -- Utilities for creating configurations
    local util = require "formatter.util"
    local prettierConfig = function()
      -- usual local prettier lays inside node modules dir
      local path = ""
      local nodes_dir = util.find_node_modules("./")
      if nodes_dir ~= nil then
        path = nodes_dir .. "/.bin/prettier"
      end
      if vim.fn.filereadable(path) == 0 then
        path = "prettier" -- global prettier to use
      end

      if path == "" then
        return nil
      end

      return {
        exe = path,
        args = { "--stdin-filepath", vim.fn.shellescape(vim.api.nvim_buf_get_name(0)) },
        stdin = true
      }
    end

    -- Provides the Format, FormatWrite, FormatLock, and FormatWriteLock commands
    require("formatter").setup {
      -- All formatter configurations are opt-in
      filetype = {
        -- lua = {function() return {exe = "lua-format", stdin = true} end},
        json                   = { prettierConfig },
        html                   = { prettierConfig },
        typescript             = { prettierConfig },
        javascript             = { prettierConfig },
        typescriptreact        = { prettierConfig },
        javascriptreact        = { prettierConfig },
        css                    = { prettierConfig },
        scss                   = { prettierConfig },
        handlebars             = { prettierConfig },
        ['typescript.glimmer'] = { prettierConfig },
        ['javascript.glimmer'] = { prettierConfig },

        -- Use the special "*" filetype for defining formatter configurations on
        -- any filetype
        ["*"]                  = {
          -- "formatter.filetypes.any" defines default configurations for any
          -- filetype
          require("formatter.filetypes.any").remove_trailing_whitespace
        }
      }
    }
  end
}
