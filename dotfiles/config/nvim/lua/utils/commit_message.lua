local Job = require("plenary.job")
local ai = require("utils.ai")

local M = {}

function M.generate()
  -- Get staged changes
  Job:new({
    command = "git",
    args = { "diff", "--staged" },
    on_exit = function(job, code)
      local diff = table.concat(job:result(), "\n")

      vim.schedule(function()
        if code ~= 0 or diff == "" then
          vim.notify("No staged changes found", vim.log.levels.WARN)
          return
        end

        local prompt = [[
Generate a commit message following the Conventional Commits convention.

Format:
<type>(<scope>): <subject>

<body>

<footer>

Rules:
- Type: feat, fix, docs, style, refactor, perf, test, chore, ci, build
- Subject: imperative mood, lowercase, no period, max 50 chars
- Body: wrap at 72 chars, explain what and why (not how)
- Footer: breaking changes, issue references
- Skip body/footer if not necessary

Be concise and professional.

IMPORTANT: Return ONLY the raw commit message text without any markdown formatting or code blocks.

Diff:
```diff
]] .. diff .. "\n```"

        ai.ask(prompt, function(text)
          if text == "" then
            vim.notify("Copilot returned empty response", vim.log.levels.ERROR)
            return
          end

          -- Strip markdown code fences if present
          -- text = text:gsub("^```%w*\n", ""):gsub("\n```$", "")

          local path = ".git/COMMIT_EDITMSG"
          local lines = vim.split(text, "\n", { plain = true })

          -- Create buffer with commit message
          local buf = vim.api.nvim_create_buf(false, true)
          vim.api.nvim_buf_set_option(buf, "filetype", "gitcommit")
          vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

          -- Write to file
          vim.api.nvim_buf_call(buf, function()
            vim.cmd("write! " .. path)
          end)

          -- Open in modal for editing
          require("utils.window").open_modal(path)

          -- Set up autocommand to commit when window is closed
          vim.api.nvim_create_autocmd("BufUnload", {
            buffer = vim.fn.bufnr(path),
            once = true,
            callback = function()
              -- Read the final commit message
              local file = io.open(path, "r")
              if not file then
                vim.notify("Failed to read commit message", vim.log.levels.ERROR)
                return
              end
              local content = file:read("*all")
              file:close()

              -- Check if message is not empty
              if content:match("^%s*$") then
                vim.notify("Commit message is empty, aborting", vim.log.levels.WARN)
                return
              end

              -- Perform the commit
              Job:new({
                command = "git",
                args = { "commit", "-F", path },
                on_exit = function(commit_job, commit_code)
                  vim.schedule(function()
                    if commit_code == 0 then
                      vim.notify("Commit created successfully", vim.log.levels.INFO)
                    else
                      local error = table.concat(commit_job:stderr_result(), "\n")
                      vim.notify("Commit failed: " .. error, vim.log.levels.ERROR)
                    end
                  end)
                end,
              }):start()
            end,
          })
        end)
      end)
    end,
  }):start()
end

return M
