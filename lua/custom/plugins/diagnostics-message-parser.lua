local M = {}

M.get_variable_pos = function(line, current_line_num)
  local pattern = "'(.-)'"
  local matches = {}
  for match in string.gmatch(line, pattern) do
    -- Find the position of the current match
    local start_pos, end_pos = string.find(line, "'" .. match .. "'", 1, true)

    -- Check if match is JS object, try to prettify it
    local is_js_object = string.find(match, "{", 1, true) ~= nil
    local match_res = is_js_object and prettify_string(match) or match
    table.insert(matches,
      {
        match = match_res,
        col_start = start_pos - 1,
        col_end = end_pos,
        line = current_line_num,
        is_raw_object =
            is_js_object
      })
  end
  return matches
end

function prettify_string(string)
  -- If JS object is too big, it will have "...;" in its children
  -- Need to replace those temporarily, otherwise prettier will fail
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
