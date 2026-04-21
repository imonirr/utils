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

-- Get repository in owner/repo format for gh CLI
local function get_repository()
  local remote_url = vim.trim(vim.fn.system("git config --get remote.origin.url"))
  if vim.v.shell_error ~= 0 then
    return nil
  end

  -- Extract owner/repo from HTTPS URL
  -- https://sj.ghe.com/owner/repo.git -> owner/repo
  local owner, repo = remote_url:match("%.com/([^/]+)/([^/%.]+)")
  if owner and repo then
    return owner .. "/" .. repo
  end

  return nil
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

-- Open PR title in floating window for editing
local function edit_pr_title(initial_title, callback)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { initial_title })
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"

  local width = math.min(80, vim.o.columns - 4)
  local height = 3
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local opts = {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " PR Title (press <CR> to confirm, <Esc> to cancel) ",
    title_pos = "center",
  }

  local win = vim.api.nvim_open_win(buf, true, opts)
  vim.wo[win].wrap = true

  -- Set keymaps
  vim.keymap.set("n", "<CR>", function()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local title = table.concat(lines, " ")
    vim.api.nvim_win_close(win, true)
    callback(vim.trim(title))
  end, { buffer = buf, noremap = true })

  vim.keymap.set("n", "<Esc>", function()
    vim.api.nvim_win_close(win, true)
    vim.notify("PR creation cancelled", vim.log.levels.WARN)
  end, { buffer = buf, noremap = true })

  -- Start in insert mode at end of line
  vim.cmd("startinsert!")
end

-- Create GitHub PR
function M.create_pr()
  get_current_branch(function(source_branch)
    if not source_branch then
      return
    end

    local repo = get_repository()
    if not repo then
      vim.notify("Failed to detect repository from git remote", vim.log.levels.ERROR)
      return
    end

    -- Extract Jira key from branch name (optional)
    local jira_key = source_branch:match("([A-Z]+%-[0-9]+)")
    if jira_key then
      vim.notify("📌 Jira: " .. jira_key, vim.log.levels.INFO)
    end

    local base_branch = get_default_branch()
    vim.notify("📌 Branch: " .. source_branch, vim.log.levels.INFO)
    vim.notify("📌 Repository: " .. repo, vim.log.levels.INFO)

    -- Get PR title from last commit
    local initial_title = vim.trim(vim.fn.system("git log -1 --pretty=%s"))

    -- Let user edit the title
    edit_pr_title(initial_title, function(title)
      if not title or title == "" then
        vim.notify("PR title cannot be empty", vim.log.levels.ERROR)
        return
      end

      -- Get description
      local description = get_pr_description(base_branch)

      vim.notify("Creating draft PR: " .. title, vim.log.levels.INFO)

      -- Escape strings for shell
      local escaped_title = title:gsub("'", "'\\''")
      local escaped_description = description:gsub("'", "'\\''")

      -- Build command
      local gh_command = string.format(
        "git push -u origin '%s' && gh pr create --draft --repo '%s' --base '%s' --head '%s' --title '%s' --body '%s'",
        source_branch,
        repo,
        base_branch,
        source_branch,
        escaped_title,
        escaped_description
      )

      -- Run in login shell to load zshrc automatically
      Job:new({
        command = "zsh",
        args = { "-lc", gh_command },
        on_exit = function(job, code)
          vim.schedule(function()
            if code == 0 then
              local output = table.concat(job:result(), "\n")
              local pr_url = output:match("https://[^\n]+")
              if pr_url then
                vim.notify("✅ PR created: " .. pr_url, vim.log.levels.INFO)
                -- Open PR in browser
                vim.fn.system("open " .. vim.fn.shellescape(pr_url))
              else
                vim.notify("✅ PR created successfully", vim.log.levels.INFO)
              end
            else
              local error_msg = table.concat(job:stderr_result(), "\n")
              vim.notify("Failed to create PR:\n" .. error_msg, vim.log.levels.ERROR)
            end
          end)
        end,
      }):start()

      -- Build command
      -- local gh_command = string.format(
      --   "git push -u origin '%s' && gh pr create --draft --repo '%s' --base '%s' --head '%s' --title '%s' --body '%s'; echo '\nPress ENTER to close'; read",
      --   source_branch,
      --   repo,
      --   base_branch,
      --   source_branch,
      --   escaped_title,
      --   escaped_description
      -- )
      --
      -- -- Create a floating terminal
      -- local buf = vim.api.nvim_create_buf(false, true)
      -- local width = math.floor(vim.o.columns * 0.8)
      -- local height = math.floor(vim.o.lines * 0.8)
      -- local row = math.floor((vim.o.lines - height) / 2)
      -- local col = math.floor((vim.o.columns - width) / 2)
      --
      -- local win = vim.api.nvim_open_win(buf, true, {
      --   relative = "editor",
      --   width = width,
      --   height = height,
      --   row = row,
      --   col = col,
      --   style = "minimal",
      --   border = "rounded",
      --   title = " Creating PR ",
      --   title_pos = "center",
      -- })
      --
      -- -- Run command in terminal
      -- vim.fn.termopen("zsh -lc " .. vim.fn.shellescape(gh_command), {
      --   on_exit = function(_, exit_code)
      --     vim.schedule(function()
      --       if exit_code == 0 then
      --         vim.notify("✅ PR created successfully", vim.log.levels.INFO)
      --       else
      --         vim.notify("❌ Failed to create PR (exit code: " .. exit_code .. ")", vim.log.levels.ERROR)
      --       end
      --     end)
      --   end,
      -- })
      --
      -- -- Set up keybinding to close the terminal
      -- vim.api.nvim_buf_set_keymap(buf, "n", "q", ":close<CR>", { noremap = true, silent = true })
      -- vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", ":close<CR>", { noremap = true, silent = true })
    end)
  end)
end

return M
