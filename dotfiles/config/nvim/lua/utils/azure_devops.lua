local Job = require("plenary.job")
local M = {}

M.config = {
  organization = os.getenv("AZURE_DEVOPS_ORG") or "",
  project = os.getenv("AZURE_DEVOPS_PROJECT") or "",
  pat = os.getenv("AZURE_DEVOPS_PAT") or "",
}

function M.setup(opts)
  M.config = vim.tbl_extend("force", M.config, opts or {})
end

-- Get current PR ID from branch or prompt user
function M.get_current_pr_id(callback)
  -- First try to get PR ID from current branch
  Job:new({
    command = "git",
    args = { "branch", "--show-current" },
    on_exit = function(job, code)
      vim.schedule(function()
        if code ~= 0 then
          vim.notify("Failed to get current branch", vim.log.levels.ERROR)
          return
        end

        local branch = vim.trim(table.concat(job:result(), "\n"))

        -- Try to find PR associated with this branch
        M.find_pr_by_branch(branch, function(pr_id)
          if pr_id then
            callback(pr_id)
          else
            -- Prompt user for PR ID
            vim.ui.input({ prompt = "Enter PR ID: " }, function(input)
              if input and input ~= "" then
                callback(input)
              end
            end)
          end
        end)
      end)
    end,
  }):start()
end
