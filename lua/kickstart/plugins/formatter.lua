return {
  'mhartington/formatter.nvim',
  config = function()
    local prettierConfig = function()
      local path = "prettier"
      local nodeModulesPath = "node_modules/prettier/bin/prettier.cjs"
      if vim.loop.fs_stat(nodeModulesPath) then
        path = nodeModulesPath
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
