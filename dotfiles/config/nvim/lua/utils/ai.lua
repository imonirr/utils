local M = {}

function M.ensure_initialized(callback)
  -- Load CopilotChat plugin if not already loaded
  local ok, chat = pcall(require, "CopilotChat")
  if not ok then
    vim.notify("CopilotChat not available", vim.log.levels.ERROR)
    return
  end

  -- If already initialized, run callback immediately
  if chat.is_initialized and chat.is_initialized() then
    callback()
    return
  end

  -- Otherwise, wait for initialization
  vim.notify("Initializing CopilotChat...", vim.log.levels.INFO)

  -- Poll for initialization (CopilotChat initializes lazily)
  local check_init
  check_init = function()
    if chat.is_initialized and chat.is_initialized() then
      vim.notify("CopilotChat ready", vim.log.levels.INFO)
      callback()
    else
      vim.defer_fn(check_init, 100)
    end
  end

  -- Trigger initialization by calling a method
  pcall(chat.ask, "")
  check_init()
end

local function normalize_response(resp)
  if type(resp) == "string" then
    return resp
  end

  if type(resp) == "table" then
    if resp.content then
      return resp.content
    end
    if vim.tbl_islist(resp) then
      return table.concat(resp, "\n")
    end
  end

  return ""
end

-- function M.ask(prompt, callback)
--   M.ensure_initialized(function()
--     require("CopilotChat").ask(prompt, {
--       selection = false,
--       callback = function(response)
--         callback(normalize_response(response))
--       end,
--     })
--   end)
-- end
--
function M.ask(prompt, callback)
  local ok, chat = pcall(require, "CopilotChat")
  if not ok then
    vim.notify("CopilotChat not available", vim.log.levels.ERROR)
    return
  end

  chat.ask(prompt, {
    selection = false,
    callback = function(response)
      callback(normalize_response(response))
    end,
  })
end

return M
