local Job = require("plenary.job")
local ai = require("utils.ai")

local M = {}

-- Push the current branch
local function push_branch(callback)
  vim.notify("🚀 Pushing current branch...", vim.log.levels.INFO)

  Job:new({
    command = "git",
    args = { "rev-parse", "--abbrev-ref", "HEAD" },
    on_exit = function(branch_job, branch_code)
      if branch_code ~= 0 then
        vim.schedule(function()
          vim.notify("Failed to get current branch", vim.log.levels.ERROR)
        end)
        return
      end

      local branch = vim.trim(table.concat(branch_job:result(), ""))

      Job:new({
        command = "git",
        args = { "push", "-u", "origin", branch },
        on_exit = function(push_job, push_code)
          vim.schedule(function()
            if push_code ~= 0 then
              local error_msg = table.concat(push_job:stderr_result(), "\n")
              vim.notify("Failed to push branch:\n" .. error_msg, vim.log.levels.ERROR)
              return
            end
            vim.notify("✅ Branch pushed successfully", vim.log.levels.INFO)
            callback()
          end)
        end,
      }):start()
    end,
  }):start()
end

-- Generate PR description
local function generate_pr_description(callback)
  vim.notify("🤖 Generating PR description...", vim.log.levels.INFO)

  -- First, try to get the default branch name
  Job:new({
    command = "git",
    args = { "symbolic-ref", "refs/remotes/origin/HEAD" },
    on_exit = function(head_job, head_code)
      local base
      if head_code == 0 then
        local remote_head = vim.trim(table.concat(head_job:result(), ""))
        base = remote_head:match("refs/remotes/(.+)") or "origin/master"
      else
        base = "origin/master"
      end

      Job:new({
        command = "git",
        args = { "merge-base", base, "HEAD" },
        on_exit = function(merge_base_job, merge_base_code)
          if merge_base_code ~= 0 then
            vim.schedule(function()
              vim.notify("Failed to find merge-base with " .. base, vim.log.levels.ERROR)
              callback(nil)
            end)
            return
          end

          local merge_base = vim.trim(table.concat(merge_base_job:result(), ""))

          Job:new({
            command = "git",
            args = { "log", merge_base .. "..HEAD", "--pretty=format:%h %s%n%b---" },
            on_exit = function(commits_job, _)
              local commits = table.concat(commits_job:result(), "\n")

              Job:new({
                command = "git",
                args = { "diff", merge_base .. "..HEAD" },
                on_exit = function(diff_job, diff_code)
                  vim.schedule(function()
                    local diff = table.concat(diff_job:result(), "\n")

                    if diff_code ~= 0 or diff == "" then
                      vim.notify("No git diff found", vim.log.levels.WARN)
                      callback(nil)
                      return
                    end

                    local prompt = [[
Generate a professional GitHub Pull Request description based on the commits and diff below.

Structure:
## Summary
## What changed
## Why this change was needed
## How to test
## Notes / Risks

Use clear bullet points and be concise.
Skip sections in structure if not necessary.

Commits:
```
]] .. commits .. [[
```

Diff:
```diff
]] .. diff .. "\n```"

                    ai.ask(prompt, function(text)
                      if text == "" then
                        vim.notify("Copilot returned empty response", vim.log.levels.ERROR)
                        callback(nil)
                        return
                      end
                      vim.notify("✅ PR description generated", vim.log.levels.INFO)
                      callback(text)
                    end)
                  end)
                end,
              }):start()
            end,
          }):start()
        end,
      }):start()
    end,
  }):start()
end

-- Main workflow function
function M.run()
  push_branch(function()
    generate_pr_description(function(description)
      require("utils.pr_create").create_pr(description)
    end)
  end)
end

return M
