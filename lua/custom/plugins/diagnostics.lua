local Layout = require("nui.layout")
local Popup = require("nui.popup")
local event = require("nui.utils.autocmd").event

local function get_highlight_color(group_name)
  local hl_id = vim.api.nvim_get_hl_id_by_name(group_name)
  if hl_id then
    local hl = vim.api.nvim_get_hl_by_id(hl_id, true)
    return hl
  end
  return nil
end

local left_popup = Popup({ border = "single" })
local right_popup = Popup({ border = "single", focusable = true, enter = true })


local layout = Layout(
  {
    position = "70%",
    size = {
      width = "80%",
      height = 40,
    },
    focusable = true,
  },
  Layout.Box({
    Layout.Box({
      Layout.Box(left_popup, { size = "20%" }),
      Layout.Box(right_popup, { size = "80%" }),
    }, { dir = "row", size = "60%" }),
  }, { dir = "col" })
)

local severity_map = {
  [1] = 'Error',
  [2] = 'Warning',
  [3] = 'Info',
  [4] = 'Hint',
  [5] = 'Deprecation',
}

-- Colors
vim.cmd [[
highlight SeverityError guifg=red
highlight SeverityWarning guifg=orange
highlight SeverityInfo guifg=blue
highlight SeverityHint guifg=green
highlight SeverityDeprecation guifg=yellow
]]

function get_severity(severity_code)
  return severity_map[severity_code]
end

function handle_left_column(diag_severity, diag_code, diag_index, diagnostics_count, current_line_num)
  local sev = get_severity(diag_severity)
  local code = "(TS" .. diag_code .. ")"

  -- Set left column
  local separator = ""
  local left_width = left_popup.win_config.width

  for i = 1, left_width do
    separator = separator .. "_"
  end

  local left_lines = { sev, code }

  -- Do not insert separator on the last line
  if diag_index ~= diagnostics_count then
    table.insert(left_lines, separator)
  end

  -- To set highlights, we need line numbers that are indexed from 0
  local normalized_line_nr = (current_line_num == 0) and 0 or (current_line_num - 1)
  local severity_pos = {
    line = normalized_line_nr,
    col_start = 0,
    col_end = #sev,
  }
  local code_pos = {
    line = current_line_num + 1,
    col_start = 0,
    col_end = #code,
  }

  vim.api.nvim_buf_set_lines(left_popup.bufnr, current_line_num, current_line_num + #left_lines, false, left_lines)
  return left_lines, severity_pos, code_pos
end

function handle_right_lines(message, diag_count, index, current_line_num)
  -- Prepare right column
  local right_lines = { message }
  local right_width = right_popup.win_config.width

  -- Ensure at least 2 rows for each message
  if #right_lines < 2 then
    table.insert(right_lines, "") -- Add an extra empty line
  end

  if index ~= diag_count then
    local separator = ""
    for i = 1, right_width do
      separator = separator .. "_"
    end
    table.insert(right_lines, separator) -- Add an extra empty line
  end

  -- Set right column
  vim.api.nvim_buf_set_lines(right_popup.bufnr, current_line_num, current_line_num + #right_lines, false, right_lines)

  return right_lines
end

local is_open = false

function Cool_Diagnostics()
  local current_line = vim.api.nvim_win_get_cursor(0)[1] - 1
  local diagnostics = vim.diagnostic.get(0, { lnum = current_line })

  -- Toggle popup
  if not is_open then
    layout:mount()
    is_open = true
  else
    layout:unmount()
    is_open = false
    return
  end

  right_popup:on(event.BufLeave, function()
    layout:unmount()
    is_open = false
  end)

  local severity_hl_ranges = {}
  local current_line_num = 0
  for index, diagnostic in ipairs(diagnostics) do
    local left_lines, severity_pos, code_pos = handle_left_column(diagnostic.severity, diagnostic.code, index,
      #diagnostics, current_line_num)

    local right_lines = handle_right_lines(diagnostic.message, #diagnostics, index, current_line_num)

    table.insert(severity_hl_ranges, severity_pos)
    print(vim.inspect(severity_pos))

    -- Update the current line number for the next diagnostic, adding an extra line for spacing
    current_line_num = current_line_num + math.max(#left_lines, #right_lines) + 1 -- +1 for the extra space
  end

  for i, range in ipairs(severity_hl_ranges) do
    local hl_group = "Diagnostic" .. severity_map[diagnostics[i].severity]
    vim.api.nvim_buf_add_highlight(left_popup.bufnr, -1, hl_group, range.line, range.col_start, range.col_end)
  end
end

vim.api.nvim_set_keymap('n', '<leader>dd', '<cmd>lua Cool_Diagnostics()<CR>', { noremap = true, silent = true })
