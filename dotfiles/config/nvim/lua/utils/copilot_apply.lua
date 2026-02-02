local M = {}

-- Parse code blocks from CopilotChat response
function M.parse_code_blocks(text)
  local blocks = {}

  -- Pattern to match code blocks with file paths
  -- Matches: ```language path=/path/to/file.lua start_line=X end_line=Y
  local pattern = "```(%w+)%s+path=([^\n]+)\n(.-)\n```"

  for lang, path_info, code in text:gmatch(pattern) do
    -- Extract path and line numbers
    local path = path_info:match("([^%s]+)")
    local start_line = path_info:match("start_line=(%d+)")
    local end_line = path_info:match("end_line=(%d+)")

    -- Clean up the path
    path = path:gsub("^%s*", ""):gsub("%s*$", ""):gsub('^"', ""):gsub('"$', "")

    table.insert(blocks, {
      language = lang,
      path = path,
      code = code,
      start_line = start_line and tonumber(start_line) or nil,
      end_line = end_line and tonumber(end_line) or nil,
    })
  end

  return blocks
end

-- Apply a code block to a file
function M.apply_code_block(block)
  local path = block.path
  local code = block.code
  local start_line = block.start_line
  local end_line = block.end_line

  -- Check if file exists
  local file_exists = vim.fn.filereadable(path) == 1

  if not file_exists then
    local choice = vim.fn.confirm(string.format("File %s doesn't exist. Create it?", path), "&Yes\n&No", 1)
    if choice ~= 1 then
      return false, "File creation cancelled"
    end
  end

  -- Read current content if file exists
  local current_lines = {}
  if file_exists then
    local file = io.open(path, "r")
    if file then
      for line in file:lines() do
        table.insert(current_lines, line)
      end
      file:close()
    end
  end

  -- Split new code into lines
  local new_lines = vim.split(code, "\n")

  -- Determine final content
  local final_lines
  if start_line and end_line and file_exists then
    -- Partial replacement: replace only the specified lines
    final_lines = {}

    -- Add lines before the change
    for i = 1, start_line - 1 do
      table.insert(final_lines, current_lines[i])
    end

    -- Add the new content
    for _, line in ipairs(new_lines) do
      table.insert(final_lines, line)
    end

    -- Add lines after the change
    for i = end_line + 1, #current_lines do
      table.insert(final_lines, current_lines[i])
    end
  else
    -- Full replacement: use new content entirely
    final_lines = new_lines
  end

  -- Write to file
  local file = io.open(path, "w")
  if not file then
    return false, "Failed to open file for writing: " .. path
  end

  for _, line in ipairs(final_lines) do
    file:write(line .. "\n")
  end
  file:close()

  -- Reload buffer if it's open
  local bufnr = vim.fn.bufnr(path)
  if bufnr ~= -1 then
    vim.api.nvim_buf_call(bufnr, function()
      vim.cmd("edit!")
    end)
  end

  return true, "Applied changes to " .. path
end

-- Get the last CopilotChat response
function M.get_last_chat_response()
  -- Try to get the CopilotChat buffer
  local chat_buffers = vim.tbl_filter(function(buf)
    local name = vim.api.nvim_buf_get_name(buf)
    return name:match("copilot%-chat") ~= nil
  end, vim.api.nvim_list_bufs())

  if #chat_buffers == 0 then
    return nil, "No CopilotChat buffer found"
  end

  -- Get the last chat buffer
  local buf = chat_buffers[#chat_buffers]
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local text = table.concat(lines, "\n")

  return text, nil
end

-- Main apply function
function M.apply_changes()
  -- Get the last chat response
  local text, err = M.get_last_chat_response()
  if err then
    vim.notify(err, vim.log.levels.ERROR)
    return
  end

  -- Parse code blocks
  local blocks = M.parse_code_blocks(text)

  if #blocks == 0 then
    vim.notify("No code blocks with file paths found in the chat response", vim.log.levels.WARN)
    return
  end

  -- Show preview of what will be applied
  local preview_lines = { "Found " .. #blocks .. " code block(s) to apply:", "" }
  for i, block in ipairs(blocks) do
    table.insert(preview_lines, string.format("%d. %s (%s)", i, block.path, block.language))
  end
  table.insert(preview_lines, "")
  table.insert(preview_lines, "Apply these changes?")

  local choice = vim.fn.confirm(table.concat(preview_lines, "\n"), "&Yes\n&No\n&Select individual", 1)

  if choice == 2 then
    vim.notify("Cancelled", vim.log.levels.INFO)
    return
  end

  local blocks_to_apply = {}
  if choice == 3 then
    -- Individual selection
    for i, block in ipairs(blocks) do
      local apply = vim.fn.confirm(string.format("Apply changes to %s?", block.path), "&Yes\n&No", 1)
      if apply == 1 then
        table.insert(blocks_to_apply, block)
      end
    end
  else
    blocks_to_apply = blocks
  end

  -- Apply the changes
  local applied = 0
  local failed = 0
  for _, block in ipairs(blocks_to_apply) do
    local success, msg = M.apply_code_block(block)
    if success then
      applied = applied + 1
      vim.notify(msg, vim.log.levels.INFO)
    else
      failed = failed + 1
      vim.notify("Failed: " .. msg, vim.log.levels.ERROR)
    end
  end

  vim.notify(
    string.format("Applied %d/%d changes", applied, applied + failed),
    applied > 0 and vim.log.levels.INFO or vim.log.levels.WARN
  )
end

-- Get the code block under cursor in the current buffer
function M.get_block_under_cursor()
  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  -- Find the code block boundaries around cursor
  local block_start = nil
  local block_end = nil
  local block_header = nil

  -- Search backwards for block start
  for i = cursor_line, 1, -1 do
    local line = lines[i]
    if line:match("^```%w+%s+path=") then
      block_start = i
      block_header = line
      break
    elseif line:match("^```$") and block_start == nil then
      -- Hit a closing block before finding opening, cursor not in a block
      return nil, "Cursor is not inside a code block with a file path"
    end
  end

  if not block_start then
    return nil, "No code block found before cursor"
  end

  -- Search forwards for block end
  for i = cursor_line, #lines do
    local line = lines[i]
    if line:match("^```$") and i > block_start then
      block_end = i
      break
    end
  end

  if not block_end then
    return nil, "Code block is not properly closed"
  end

  -- Extract block info from header
  local lang, path_info = block_header:match("```(%w+)%s+path=([^\n]+)")
  if not lang or not path_info then
    return nil, "Could not parse block header"
  end

  -- Extract path and line numbers
  local path = path_info:match("([^%s]+)")
  local start_line = path_info:match("start_line=(%d+)")
  local end_line = path_info:match("end_line=(%d+)")

  -- Clean up the path
  path = path:gsub("^%s*", ""):gsub("%s*$", ""):gsub('^"', ""):gsub('"$', "")

  -- Extract code content (excluding the opening and closing ```)
  local code_lines = {}
  for i = block_start + 1, block_end - 1 do
    table.insert(code_lines, lines[i])
  end
  local code = table.concat(code_lines, "\n")

  return {
    language = lang,
    path = path,
    code = code,
    start_line = start_line and tonumber(start_line) or nil,
    end_line = end_line and tonumber(end_line) or nil,
  },
    nil
end

-- Apply the code block under cursor
function M.apply_block_under_cursor()
  local block, err = M.get_block_under_cursor()
  if err then
    vim.notify(err, vim.log.levels.WARN)
    return
  end

  -- Show confirmation with preview
  local preview
  if block.start_line and block.end_line then
    preview = string.format(
      "Apply changes to:\n%s\n\nLanguage: %s\nLines: %d-%d",
      block.path,
      block.language,
      block.start_line,
      block.end_line
    )
  else
    preview =
      string.format("Apply changes to:\n%s\n\nLanguage: %s\n(Full file replacement)", block.path, block.language)
  end

  local choice = vim.fn.confirm(preview, "&Yes\n&No", 1)

  if choice ~= 1 then
    vim.notify("Cancelled", vim.log.levels.INFO)
    return
  end

  -- Remember current window (CopilotChat window)
  local copilot_win = vim.api.nvim_get_current_win()

  -- Find the window that's not CopilotChat (the main editor window)
  local target_win = nil
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local buftype = vim.api.nvim_buf_get_option(buf, "buftype")
    -- Skip special buffers (like CopilotChat)
    if buftype == "" and win ~= copilot_win then
      target_win = win
      break
    end
  end

  -- Apply the block
  local success, msg = M.apply_code_block(block)
  if success then
    vim.notify(msg, vim.log.levels.INFO)

    -- Switch to the target window (main editor) before opening the file
    if target_win then
      vim.api.nvim_set_current_win(target_win)
    end

    -- Open the file in the target window
    vim.cmd("edit " .. vim.fn.fnameescape(block.path))

    -- Position cursor at the changed lines
    if block.start_line then
      vim.cmd("normal! " .. block.start_line .. "G")
    else
      vim.cmd("normal! gg")
    end

    -- Center the view
    vim.cmd("normal! zz")
  else
    vim.notify("Failed: " .. msg, vim.log.levels.ERROR)
  end
end

return M
