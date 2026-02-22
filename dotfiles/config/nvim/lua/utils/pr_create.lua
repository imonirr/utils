local Job = require("plenary.job")

local M = {}

-- Get current branch name
local function get_current_branch(callback)
  Job:new({
    command = "git",
    args = { "branch", "--show-current" },
    on_exit = function(job, code)
      vim.schedule(function()
        if code ~= 0 then
          vim.notify("Failed to get current branch", vim.log.levels.ERROR)
          callback(nil)
          return
        end
        local branch = vim.trim(table.concat(job:result(), ""))
        callback(branch)
      end)
    end,
  }):start()
end

-- Get the default remote branch (main/master)
local function get_default_branch()
  local result = vim.fn.system("git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null")
  if vim.v.shell_error == 0 then
    local remote_head = vim.trim(result)
    local branch = remote_head:match("refs/remotes/origin/(.+)")
    if branch then
      return branch
    end
  end
  -- Fallback to checking what exists
  if vim.fn.system("git rev-parse --verify origin/main 2>/dev/null") then
    if vim.v.shell_error == 0 then
      return "main"
    end
  end
  return "master"
end

-- Get list of commits for PR description
local function get_commits_summary(base_branch)
  local result = vim.fn.system("git log " .. base_branch .. "..HEAD --oneline")
  return vim.trim(result)
end

-- Get PR description from file or commits
local function get_pr_description(base_branch)
  local desc_file = ".git/PR_DESCRIPTION.md"
  if vim.fn.filereadable(desc_file) == 1 then
    vim.notify("🧠 Using PR description from " .. desc_file, vim.log.levels.INFO)
    local lines = vim.fn.readfile(desc_file)
    return table.concat(lines, "\n")
  else
    vim.notify("📝 Collecting commit summary…", vim.log.levels.INFO)
    local commits = get_commits_summary(base_branch)
    return "## Changes\n" .. commits
  end
end

-- Create Azure DevOps PR
function M.create_pr()
  get_current_branch(function(source_branch)
    if not source_branch then
      return
    end

    -- Extract Jira key from branch name (optional)
    local jira_key = source_branch:match("([A-Z]+%-[0-9]+)")
    if jira_key then
      vim.notify("📌 Jira: " .. jira_key, vim.log.levels.INFO)
    end

    local base_branch = get_default_branch()
    vim.notify("📌 Branch: " .. source_branch, vim.log.levels.INFO)

    -- Get PR title from last commit
    local title = vim.trim(vim.fn.system("git log -1 --pretty=%s"))

    -- Get description
    local description = get_pr_description(base_branch)

    vim.notify("Creating draft PR: " .. title, vim.log.levels.INFO)

    -- Push branch first
    Job:new({
      command = "git",
      args = { "push", "-u", "origin", source_branch },
      on_exit = function(push_job, push_code)
        vim.schedule(function()
          if push_code ~= 0 then
            local error_msg = table.concat(push_job:stderr_result(), "\n")
            vim.notify("Failed to push branch:\n" .. error_msg, vim.log.levels.ERROR)
            return
          end

          -- Create PR using Azure CLI (same as bash script)
          Job:new({
            command = "az",
            args = {
              "repos",
              "pr",
              "create",
              "--draft",
              "--source-branch",
              source_branch,
              "--target-branch",
              base_branch,
              "--title",
              title,
              "--description",
              description,
              "--output",
              "json",
            },
            on_exit = function(job, code)
              vim.schedule(function()
                if code ~= 0 then
                  local error_msg = table.concat(job:stderr_result(), "\n")
                  vim.notify("Failed to create PR:\n" .. error_msg, vim.log.levels.ERROR)
                  return
                end

                local output = table.concat(job:result(), "\n")
                local pr_data = vim.fn.json_decode(output)

                -- Extract PR URL (same logic as bash script)
                local pr_url = pr_data.repository.webUrl .. "/pullrequest/" .. tostring(pr_data.pullRequestId)

                if not pr_url or pr_url:match("null") then
                  pr_url = pr_data.webUrl
                end

                vim.notify("✅ PR created:\n" .. pr_url, vim.log.levels.INFO)

                -- Copy URL to clipboard
                vim.fn.setreg("+", pr_url)

                -- Open in browser (macOS)
                vim.fn.system('open -a "Google Chrome" "' .. pr_url .. '"')
              end)
            end,
          }):start()
        end)
      end,
    }):start()
  end)
end

return M
