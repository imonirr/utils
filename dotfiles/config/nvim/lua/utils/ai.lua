local M = {}

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

function M.ask(prompt, callback)
  require("CopilotChat").ask(prompt, {
    selection = false,
    callback = function(response)
      callback(normalize_response(response))
    end,
  })
end

return M
