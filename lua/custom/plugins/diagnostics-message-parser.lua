local M = {}

M.get_variable_pos = function(line, current_line_num)
  local pattern = "'(.-)'"
  local matches = {}
  for match in string.gmatch(line, pattern) do
    -- Find the position of the current match
    local start_pos, end_pos = string.find(line, "'" .. match .. "'", 1, true)
    -- Check if match is JS object, try to prettify it
    local is_js_object = string.find(match, "{", 1, true) ~= nil

    if is_js_object then
      local prettified = prettify_string(match)
      table.insert(matches,
        { match = prettified, col_start = start_pos - 1, col_end = end_pos, line = current_line_num, is_raw_object = true })
    else
      table.insert(matches,
        {
          match = match,
          col_start = start_pos - 1,
          col_end = end_pos,
          line = current_line_num,
          is_raw_object =
              is_js_object
        })
    end
  end
  return matches
end

M.break_new_lines = function(message)
  local body_lines = {}
  for line in vim.gsplit(message, "\n") do
    table.insert(body_lines, line)
  end
  return body_lines
end

function prettify_string(string)
  local preprocess = string:gsub("(%.%.%.%;)", " REPLACE_KEY: null ")
  local command = "echo \"" .. preprocess .. "\" | prettier --parser typescript"
  local output = vim.fn.system(command)
  local postprocess = output:gsub("(REPLACE_KEY: null)", "...")
  print("PRETIFFY OUTPUT:")
  print(postprocess)
  print("END PRETIFFY OUTPUT")
  return postprocess
end

return M
