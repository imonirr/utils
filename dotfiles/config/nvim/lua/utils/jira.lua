local Job = require("plenary.job")
-- lua require("utils.jira").fetch_ticket("ASK-1932", function(resp) print(resp) end)
local M = {}

-- Configuration (you'll need to set these)
M.config = {
  host = os.getenv("JIRA_BASE_URL") or "", -- e.g., "yourcompany.atlassian.net"
  email = os.getenv("JIRA_EMAIL") or "",
  api_token = os.getenv("JIRA_API_TOKEN") or "",
}

function M.setup(opts)
  M.config = vim.tbl_extend("force", M.config, opts or {})
end

function M.parse_adf_to_text(adf)
  if type(adf) == "string" then
    return adf
  end

  if not adf or not adf.content then
    return ""
  end

  local function extract_text(node)
    if not node then
      return ""
    end

    if node.type == "text" then
      return node.text or ""
    end

    local text = ""
    if node.content then
      for _, child in ipairs(node.content) do
        local child_text = extract_text(child)
        if child_text ~= "" then
          text = text .. child_text
        end
      end
    end

    -- Add line breaks for certain node types
    if node.type == "paragraph" or node.type == "heading" then
      text = text .. "\n"
    elseif node.type == "codeBlock" then
      text = "```\n" .. text .. "```\n"
    elseif node.type == "bulletList" or node.type == "orderedList" then
      text = text .. "\n"
    elseif node.type == "listItem" then
      text = "- " .. text
    end

    return text
  end

  return extract_text(adf):gsub("\n\n+", "\n\n"):gsub("^%s+", ""):gsub("%s+$", "")
end

function M.parse_ticket(json_str)
  local ok, data = pcall(vim.json.decode, json_str)
  if not ok then
    return nil, "Failed to parse JSON response"
  end

  if data.errorMessages then
    return nil, table.concat(data.errorMessages, ", ")
  end

  local description = M.parse_adf_to_text(data.fields.description)
  if description == "" then
    description = "No description"
  end

  local ticket = {
    key = data.key,
    summary = data.fields.summary,
    description = description,
    status = data.fields.status.name,
    assignee = data.fields.assignee and data.fields.assignee.displayName or "Unassigned",
    type = data.fields.issuetype.name,
  }

  return ticket, nil
end

function M.format_ticket(ticket)
  local lines = {
    "# " .. ticket.key .. ": " .. ticket.summary,
    "",
    "**Type:** " .. ticket.type,
    "**Status:** " .. ticket.status,
    "**Assignee:** " .. ticket.assignee,
    "",
    "## Description",
    "",
    ticket.description,
  }
  return table.concat(lines, "\n")
end

function M.fetch_ticket(ticket_id, callback)
  if M.config.host == "" or M.config.email == "" or M.config.api_token == "" then
    vim.notify("Jira credentials not configured", vim.log.levels.ERROR)
    return
  end

  local url = string.format("%s/rest/api/3/issue/%s", M.config.host, ticket_id)
  local auth =
    vim.fn.system(string.format("echo -n '%s:%s' | base64", M.config.email, M.config.api_token)):gsub("\n", "")

  Job:new({
    command = "curl",
    args = {
      "-s",
      "-H",
      "Authorization: Basic " .. auth,
      "-H",
      "Accept: application/json",
      url,
    },
    on_exit = function(job, code)
      vim.schedule(function()
        if code ~= 0 then
          vim.notify("Failed to fetch Jira ticket (code: " .. code .. ")", vim.log.levels.ERROR)
          return
        end
        local response = table.concat(job:result(), "\n")
        callback(response)
      end)
    end,
  }):start()
end

return M
