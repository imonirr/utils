local azure_devops = require("utils.azure_devops")
local CopilotChat = require("CopilotChat")
local M = {}

function M.parse_pr_data(pr_json, iterations_json)
  local ok, pr = pcall(vim.json.decode, pr_json)
  if not ok then
    return nil, "Failed to parse PR JSON"
  end

  local iterations = nil
  if iterations_json then
    local iter_ok, iter_data = pcall(vim.json.decode, iterations_json)
    if iter_ok then
      iterations = iter_data
    end
  end

  return {
    id = pr.pullRequestId,
    title = pr.title,
    description = pr.description or "No description",
    source_branch = pr.sourceRefName:gsub("refs/heads/", ""),
    target_branch = pr.targetRefName:gsub("refs/heads/", ""),
    status = pr.status,
    created_by = pr.createdBy.displayName,
    reviewers = pr.reviewers or {},
    iterations = iterations,
  },
    nil
end

function M.fetch_pr_changes(pr_id, callback)
  if azure_devops.config.organization == "" or azure_devops.config.pat == "" then
    vim.notify("Azure DevOps credentials not configured", vim.log.levels.ERROR)
    return
  end

  local url = string.format(
    "https://dev.azure.com/%s/%s/_apis/git/pullrequests/%s/iterations/1/changes?api-version=7.0",
    azure_devops.config.organization,
    azure_devops.config.project,
    pr_id
  )

  local auth = vim.fn.system("echo -n ':" .. azure_devops.config.pat .. "' | base64"):gsub("\n", "")

  require("plenary.job")
    :new({
      command = "curl",
      args = {
        "-s",
        "-H",
        "Authorization: Basic " .. auth,
        "-H",
        "Content-Type: application/json",
        url,
      },
      on_exit = function(job, code)
        vim.schedule(function()
          if code ~= 0 then
            callback(nil, "Failed to fetch PR changes")
            return
          end

          local response = table.concat(job:result(), "\n")
          local ok, data = pcall(vim.json.decode, response)

          if not ok then
            callback(nil, "Failed to parse changes JSON")
            return
          end

          callback(data, nil)
        end)
      end,
    })
    :start()
end

function M.format_pr_for_review(pr, changes)
  local lines = {
    "# PR #" .. pr.id .. ": " .. pr.title,
    "",
    "**Author:** " .. pr.created_by,
    "**Source:** " .. pr.source_branch .. " → **Target:** " .. pr.target_branch,
    "**Status:** " .. pr.status,
    "",
    "## Description",
    "",
    pr.description,
    "",
    "## Changed Files",
    "",
  }

  if changes and changes.changeEntries then
    for _, change in ipairs(changes.changeEntries) do
      local change_type = change.changeType or "edit"
      local path = change.item.path or "unknown"
      table.insert(lines, string.format("- [%s] %s", change_type, path))
    end
  else
    table.insert(lines, "No file changes found")
  end

  return table.concat(lines, "\n")
end

function M.start_pr_review()
  vim.notify("Fetching PR details...", vim.log.levels.INFO)

  azure_devops.get_current_pr_id(function(pr_id)
    if not pr_id then
      vim.notify("No PR ID found", vim.log.levels.ERROR)
      return
    end

    azure_devops.fetch_pr_details(pr_id, function(pr_json, iterations_json)
      local pr, err = M.parse_pr_data(pr_json, iterations_json)

      if err then
        vim.notify("Error: " .. err, vim.log.levels.ERROR)
        return
      end

      M.fetch_pr_changes(pr_id, function(changes, changes_err)
        if changes_err then
          vim.notify("Error fetching changes: " .. changes_err, vim.log.levels.WARN)
        end

        local formatted = M.format_pr_for_review(pr, changes)

        local prompt = string.format(
          [[Please review this Azure DevOps Pull Request:

%s

Provide a comprehensive code review including:
1. **Potential bugs or issues** - Identify any logic errors, edge cases, or potential runtime issues
2. **Code quality improvements** - Suggest better patterns, cleaner code, or adherence to best practices
3. **Security concerns** - Flag any security vulnerabilities or sensitive data exposure
4. **Performance considerations** - Point out any performance bottlenecks or inefficiencies
5. **Testing suggestions** - Recommend what should be tested
6. **Overall assessment** - Rate the PR and provide actionable feedback

Be specific and constructive in your feedback.]],
          formatted
        )

        CopilotChat.ask(prompt)
        vim.notify("PR review started in CopilotChat!", vim.log.levels.INFO)
      end)
    end)
  end)
end

return M
