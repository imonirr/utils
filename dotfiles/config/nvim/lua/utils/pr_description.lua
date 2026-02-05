local Job = require("plenary.job")
local ai = require("utils.ai")

local M = {}

function M.generate_v2()
  local base = "origin/master"

  -- First, find the merge-base
  Job:new({
    command = "git",
    args = { "merge-base", base, "HEAD" },
    on_exit = function(merge_base_job, merge_base_code)
      if merge_base_code ~= 0 then
        vim.schedule(function()
          vim.notify("Failed to find merge-base", vim.log.levels.ERROR)
        end)
        return
      end

      local merge_base = vim.trim(table.concat(merge_base_job:result(), ""))

      -- Get the commits from merge-base to HEAD
      Job:new({
        command = "git",
        args = { "log", merge_base .. "..HEAD", "--pretty=format:%h %s%n%b---" },
        on_exit = function(commits_job, _)
          local commits = table.concat(commits_job:result(), "\n")

          -- Get only committed changes (merge-base..HEAD, not including working tree)
          Job:new({
            command = "git",
            args = { "diff", merge_base .. "..HEAD" },
            on_exit = function(diff_job, diff_code)
              local diff = table.concat(diff_job:result(), "\n")

              vim.schedule(function()
                if diff_code ~= 0 or diff == "" then
                  vim.notify("No git diff found", vim.log.levels.WARN)
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
                    return
                  end
                  local path = ".git/PR_DESCRIPTION.md"
                  local lines = vim.split(text, "\n", { plain = true })
                  local buf = vim.api.nvim_create_buf(false, true)
                  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
                  vim.api.nvim_buf_call(buf, function()
                    vim.cmd("write! " .. path)
                  end)
                  vim.notify("PR description written to " .. path)
                  require("utils.window").open_modal(path)
                end)
              end)
            end,
          }):start()
        end,
      }):start()
    end,
  }):start()
end

return M
