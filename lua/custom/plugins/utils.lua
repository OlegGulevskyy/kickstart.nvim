local M = {}

M.break_new_lines = function(message)
  local body_lines = {}
  for line in vim.gsplit(message, "\n") do
    table.insert(body_lines, line)
  end
  return body_lines
end

local severity_map = {
  [1] = 'Error',
  [2] = 'Warning',
  [3] = 'Info',
  [4] = 'Hint',
  [5] = 'Deprecation',
}

M.get_severity = function(severity_code)
  return severity_map[severity_code]
end

M.get_code = function(code)
  return "(TS" .. code .. ")"
end

return M
