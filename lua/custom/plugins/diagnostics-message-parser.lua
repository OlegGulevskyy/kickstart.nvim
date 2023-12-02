local M = {}

M.get_variable_pos = function(line, current_line_num)
  local pattern = "'(.-)'"
  local matches = {}
  for match in string.gmatch(line, pattern) do
    -- Find the position of the current match
    local start_pos, end_pos = string.find(line, "'" .. match .. "'", 1, true)
    table.insert(matches, { match = match, col_start = start_pos - 1, col_end = end_pos, line = current_line_num })
  end
  return matches
end

M.parse_body = function(message)
  local body_lines = {}
  for line in vim.gsplit(message, "\n") do
    table.insert(body_lines, line)
  end
  return body_lines
end

return M
