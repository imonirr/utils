local Job = require("plenary.job")
local ai = require("utils.ai")

local M = {}

function M.generate()
  local base = "origin/master" -- change if needed

  Job:new({
    command = "git",
    args = { "diff", base },
    on_exit = function(job, code)
      local diff = table.concat(job:result(), "\n")

      vim.schedule(function()
        if code ~= 0 or diff == "" then
          vim.notify("No git diff found", vim.log.levels.WARN)
          return
        end
        -- Summarize the current git diff as a pull request description.
        -- Include:
        -- - What changed
        -- - Why
        -- - Testing notes

        local prompt = [[
Generate a professional GitHub Pull Request description.

Structure:

## Summary
## What changed
## Why this change was needed
## How to test
## Notes / Risks

Use clear bullet points and be concise.
Skip sections in structure if not necessary.

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
          -- Open file for review/edit
          require("utils.window").open_modal(path)
        end)
      end)
    end,
  }):start()
end

function M.generate_v2()
  local base = "origin/master"

  -- ```
  --
  -- **Key changes:**
  --
  -- 1. Added a nested `git log` call to fetch commits between `base..HEAD`
  -- 2. The `--pretty=format:%h %s%n%b---` gives you:
  --    - `%h` - short hash
  --    - `%s` - subject line
  --    - `%b` - body
  --    - `---` - separator between commits
  --
  -- **Alternative format options you might prefer:**
  -- ```lua
  -- -- More detailed with author and date
  -- args = { "log", base .. "..HEAD", "--pretty=format:%h - %s (%an, %ar)%n%b---" }
  --
  -- -- Just subject lines (minimal)
  -- args = { "log", base .. "..HEAD", "--oneline" }
  --
  -- -- With full commit message
  -- args = { "log", base .. "..HEAD", "--pretty=format:### %s%n%b" }
  -- ```
  --
  -- **Tip:** If the combined context gets too large, you could truncate the diff or only include commit subjects. You could also add `--stat` to the diff to give a file-level summary before the full diff.
  --
  --
  --

  -- First, get the commits
  Job:new({
    command = "git",
    args = { "log", base .. "..HEAD", "--pretty=format:%h %s%n%b---" },
    on_exit = function(commits_job, commits_code)
      local commits = table.concat(commits_job:result(), "\n")

      -- Then get the diff
      Job:new({
        command = "git",
        args = { "diff", base },
        on_exit = function(diff_job, diff_code)
          local diff = table.concat(diff_job:result(), "\n")

          vim.schedule(function()
            if diff_code ~= 0 or diff == "" then
              vim.notify("No git diff found", vim.log.levels.WARN)
              return
            end

            local prompt = [[
Generate a professional GitHub Pull Request description.
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
end

return M
