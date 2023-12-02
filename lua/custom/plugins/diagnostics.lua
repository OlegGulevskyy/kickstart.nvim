local Layout = require("nui.layout")
local Popup = require("nui.popup")
local event = require("nui.utils.autocmd").event
local parser = require("custom.plugins.diagnostics-message-parser")

local popup = Popup({
  enter = true,
  focusable = true,
  border = {
    style = "rounded",
  },
  position = "50%",
  size = {
    width = "80%",
    height = "60%",
  },
})

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

-- Prepare header
function handle_header(diag_severity, diag_code, diagnostics_count, current_line_num)
  local sev = get_severity(diag_severity)
  local code = "(TS" .. diag_code .. ")"

  -- Set left column
  local pop_width = popup.win_config.width
  local header_lines = { sev, code }

  -- To set highlights, we need line numbers that are indexed from 0
  local normalized_line_nr = (current_line_num == 0) and 0 or (current_line_num - 1)
  local severity_pos = {
    line = normalized_line_nr,
    col_start = 0,
    col_end = #sev,
  }

  local code_pos = {
    line = severity_pos.line + 1,
    col_start = 0,
    col_end = #code,
  }

  vim.api.nvim_buf_set_lines(popup.bufnr, current_line_num, current_line_num + #header_lines, false, header_lines)
  return header_lines, severity_pos, code_pos
end

-- Prepare body
function handle_body(message, diag_count, index, current_line_num)
  local normalized_line_nr = (current_line_num == 0) and 0 or (current_line_num - 1)
  local message_start_pos = normalized_line_nr + 2

  local body_lines = parser.parse_body(message, message_start_pos)
  -- Ensure at least 2 rows for each message
  if #body_lines < 2 then
    table.insert(body_lines, "") -- Add an extra empty line
  end

  local vars = {}
  local i = 0
  for _, line in ipairs(body_lines) do
    local tvars = parser.get_variable_pos(line, message_start_pos + i)
    for _, j in ipairs(tvars) do
      table.insert(vars, j)
    end
    i = i + 1
  end

  local pop_width = popup.win_config.width

  if index ~= diag_count then
    local separator = ""
    for i = 1, pop_width do
      separator = separator .. "_"
    end
    table.insert(body_lines, separator) -- Add an extra empty line
  end

  local message_end_pos = message_start_pos + #body_lines

  -- Set right column
  vim.api.nvim_buf_set_lines(popup.bufnr, message_start_pos, message_end_pos, false, body_lines)

  return body_lines, message_end_pos, vars
end

local is_open = false

function Cool_Diagnostics()
  local current_line = vim.api.nvim_win_get_cursor(0)[1] - 1
  local diagnostics = vim.diagnostic.get(0, { lnum = current_line })

  -- Toggle popup
  if not is_open then
    popup:mount()
    is_open = true
  else
    popup:unmount()
    is_open = false
    return
  end

  popup:on(event.BufLeave, function()
    popup:unmount()
    is_open = false
  end)

  local severity_hl_ranges = {}
  local code_hl_ranges = {}
  local vars_hl_ranges = {}
  local current_line_num = 0

  for index, diagnostic in ipairs(diagnostics) do
    local header_lines, severity_pos, code_pos = handle_header(diagnostic.severity, diagnostic.code, #diagnostics,
      current_line_num)

    local body_lines, message_end_pos, vars = handle_body(diagnostic.message, #diagnostics, index, current_line_num)

    table.insert(severity_hl_ranges, severity_pos)
    table.insert(code_hl_ranges, code_pos)
    for _, var in ipairs(vars) do
      table.insert(vars_hl_ranges, var)
    end

    -- Update the current line number for the next diagnostic, adding an extra line for spacing
    current_line_num = current_line_num + math.max(#header_lines, message_end_pos) + 1 -- +1 for the extra space
  end

  for i, range in ipairs(severity_hl_ranges) do
    local hl_group = "Diagnostic" .. severity_map[diagnostics[i].severity]
    vim.api.nvim_buf_add_highlight(popup.bufnr, -1, hl_group, range.line, range.col_start, range.col_end)
  end

  for _, range in ipairs(code_hl_ranges) do
    local hl_group = "Comment"
    vim.api.nvim_buf_add_highlight(popup.bufnr, -1, hl_group, range.line, range.col_start, range.col_end)
  end

  for _, range in ipairs(vars_hl_ranges) do
    local hl_group = "String"
    vim.api.nvim_buf_add_highlight(popup.bufnr, -1, hl_group, range.line, range.col_start, range.col_end)
  end
end

vim.api.nvim_set_keymap('n', '<leader>dd', '<cmd>lua Cool_Diagnostics()<CR>', { noremap = true, silent = true })
