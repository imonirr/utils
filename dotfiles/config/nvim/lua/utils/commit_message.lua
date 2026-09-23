local Job = require("plenary.job")
local ai = require("utils.ai")

local M = {}

function M.generate()
  local cwd = vim.fn.getcwd()

  -- Resolve this worktree's Git directory before asynchronous work begins.
  Job:new({
    command = "git",
    args = { "rev-parse", "--path-format=absolute", "--git-path", "COMMIT_EDITMSG" },
    cwd = cwd,
    on_exit = function(path_job, path_code)
      local path = table.concat(path_job:result(), "")

      if path_code ~= 0 or path == "" then
        vim.schedule(function()
          vim.notify("Unable to resolve the Git commit message path", vim.log.levels.ERROR)
        end)
        return
      end

      Job:new({
        command = "git",
        args = { "branch", "--show-current" },
        cwd = cwd,
        on_exit = function(branch_job, branch_code)
          if branch_code ~= 0 then
            vim.schedule(function()
              vim.notify("Unable to determine the current Git branch", vim.log.levels.ERROR)
            end)
            return
          end

          local branch_name = table.concat(branch_job:result(), "")
          local ticket_id = branch_name:match("([A-Z]+%-[0-9]+)")

          Job:new({
            command = "git",
            args = { "diff", "--staged" },
            cwd = cwd,
            on_exit = function(diff_job, diff_code)
              local diff = table.concat(diff_job:result(), "\n")

              vim.schedule(function()
                if diff_code ~= 0 then
                  vim.notify("Unable to read staged changes", vim.log.levels.ERROR)
                  return
                end

                if diff == "" then
                  vim.notify("No staged changes found", vim.log.levels.WARN)
                  return
                end

                local format_line = ticket_id and string.format("%s: <subject>", ticket_id)
                  or "<type>(<scope>): <subject>"
                local prompt = string.format(
                  [[
Generate a commit message following the Conventional Commits convention.

Format:
%s

<body>

<footer>

Rules:
- Type: feat, fix, docs, style, refactor, perf, test, chore, ci, build
- Subject: imperative mood, lowercase, no period, max 50 chars
- Body: wrap at 72 chars, explain what and why (not how)
- Footer: breaking changes, issue references
- Skip body/footer if not necessary

Be concise and professional. minimum information.

IMPORTANT: Return ONLY the raw commit message text without any markdown formatting or code blocks.

Diff:
```diff
]],
                  format_line
                ) .. diff .. "\n```"

                ai.ask(prompt, function(text)
                  if text == "" then
                    vim.notify("Copilot returned empty response", vim.log.levels.ERROR)
                    return
                  end

                  local lines = vim.split(text, "\n", { plain = true })
                  local buf = vim.api.nvim_create_buf(false, true)
                  vim.bo[buf].filetype = "gitcommit"
                  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

                  local wrote, write_error = pcall(vim.api.nvim_buf_call, buf, function()
                    vim.cmd("write! " .. vim.fn.fnameescape(path))
                  end)
                  if not wrote then
                    vim.notify("Failed to write commit message: " .. write_error, vim.log.levels.ERROR)
                    return
                  end

                  require("utils.window").open_modal(path)

                  vim.api.nvim_create_autocmd("BufUnload", {
                    buffer = vim.fn.bufnr(path),
                    once = true,
                    callback = function()
                      local file, read_error = io.open(path, "r")
                      if not file then
                        vim.notify(
                          "Failed to read commit message: " .. (read_error or "unknown error"),
                          vim.log.levels.ERROR
                        )
                        return
                      end
                      local content = file:read("*all")
                      file:close()

                      if content:match("^%s*$") then
                        vim.notify("Commit message is empty, aborting", vim.log.levels.WARN)
                        return
                      end

                      Job:new({
                        command = "git",
                        args = { "commit", "-F", path },
                        cwd = cwd,
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
        end,
      }):start()
    end,
  }):start()
end

return M
