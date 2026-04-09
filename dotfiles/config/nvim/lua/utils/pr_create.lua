local M = {}
local Job = require("plenary.job")

-- Get current git branch
local function get_current_branch(callback)
  Job:new({
    command = "git",
    args = { "branch", "--show-current" },
    on_exit = function(j, return_val)
      vim.schedule(function()
        if return_val == 0 then
          local branch = vim.trim(table.concat(j:result(), "\n"))
          callback(branch)
        else
          vim.notify("Failed to get current branch", vim.log.levels.ERROR)
          callback(nil)
        end
      end)
    end,
  }):start()
end

-- Get default branch (main or master)
local function get_default_branch()
  local result = vim.fn.system("git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null")
  if vim.v.shell_error == 0 then
    return vim.trim(result):match("refs/remotes/origin/(.+)")
  end
  return "main" -- fallback
end

-- Get repository origin URL
local function get_repository_url()
  local remote_url = vim.trim(vim.fn.system("git config --get remote.origin.url"))
  if vim.v.shell_error ~= 0 then
    return nil
  end

  -- Convert SSH to HTTPS format if needed
  -- git@github.company.com:owner/repo.git -> https://github.company.com/owner/repo
  local https_url = remote_url:gsub("^git@([^:]+):(.+)%.git$", "https://%1/%2")
  if https_url == remote_url then
    -- Already HTTPS, just remove .git suffix if present
    https_url = remote_url:gsub("%.git$", "")
  end

  return https_url
end

-- Get list of commits for PR description
local function get_commits_summary(base_branch)
  local result = vim.fn.system("git log " .. base_branch .. "..HEAD --oneline")
  return vim.trim(result)
end

-- Get PR description from file or commits
local function get_pr_description(base_branch)
  local pr_file = vim.fn.getcwd() .. "/.git/PR_DESCRIPTION.md"
  if vim.fn.filereadable(pr_file) == 1 then
    vim.notify("🧠 Using PR description from .git/PR_DESCRIPTION.md", vim.log.levels.INFO)
    return vim.fn.join(vim.fn.readfile(pr_file), "\n")
  else
    return get_commits_summary(base_branch)
  end
end

-- Create GitHub PR
function M.create_pr()
  get_current_branch(function(source_branch)
    if not source_branch then
      return
    end

    local repo_url = get_repository_url()
    if not repo_url then
      vim.notify("Failed to detect repository URL from git remote", vim.log.levels.ERROR)
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

          -- Create PR using GitHub CLI with repo URL
          Job:new({
            command = "gh",
            args = {
              "pr",
              "create",
              "--draft",
              "--repo",
              repo_url,
              "--base",
              base_branch,
              "--head",
              source_branch,
              "--title",
              title,
              "--body",
              description,
            },
            on_exit = function(pr_job, pr_code)
              vim.schedule(function()
                if pr_code == 0 then
                  local pr_url = vim.trim(table.concat(pr_job:result(), "\n"))
                  vim.notify("✅ PR created: " .. pr_url, vim.log.levels.INFO)
                else
                  local error_msg = table.concat(pr_job:stderr_result(), "\n")
                  vim.notify("Failed to create PR:\n" .. error_msg, vim.log.levels.ERROR)
                end
              end)
            end,
          }):start()
        end)
      end,
    }):start()
  end)
end

return M
