local jira = require("utils.jira")
local CopilotChat = require("CopilotChat")

local M = {}

function M.start_with_ticket()
  vim.ui.input({ prompt = "Enter Jira ticket ID: " }, function(ticket_id)
    if not ticket_id or ticket_id == "" then
      return
    end

    -- Show loading message
    vim.notify("Fetching Jira ticket " .. ticket_id .. "...", vim.log.levels.INFO)

    jira.fetch_ticket(ticket_id, function(response)
      local ticket, err = jira.parse_ticket(response)

      if err then
        vim.notify("Error: " .. err, vim.log.levels.ERROR)
        return
      end

      local formatted = jira.format_ticket(ticket)

      -- Create the prompt for CopilotChat
      local prompt = string.format(
        [[I want to work on this Jira ticket:

%s

Please analyze this ticket and wait for me to provide:
1. Relevant files that need to be modified
2. Additional context or constraints
3. Specific instructions on how to implement this

Once you have all the information, provide your code changes in this exact format:

    ```language path=/absolute/path/to/file.ext
    <complete file content here>
    ```

Make sure to always include the full absolute file path in the code block header.]],
        formatted
      )

      -- Open CopilotChat in agent mode with the ticket context
      CopilotChat.ask(prompt)

      vim.notify("Jira ticket loaded into CopilotChat!", vim.log.levels.INFO)
    end)
  end)
end

return M
