local M = {}

-- Extract issue number from branch name
local function extract_issue_number(branch_name)
  local issue = branch_name:match("/[A-Z]+-(%d+)")
  return issue
end

-- Get current git branch
local function get_current_branch()
  local handle = io.popen("git rev-parse --abbrev-ref HEAD 2>/dev/null")
  if not handle then
    return nil
  end
  local branch = handle:read("*a"):gsub("%s+", "")
  handle:close()
  return branch ~= "" and branch or nil
end

-- Get git repo root directory
local function get_repo_root()
  local handle = io.popen("git rev-parse --show-toplevel 2>/dev/null")
  if not handle then
    return nil
  end
  local root = handle:read("*a"):gsub("%s+", "")
  handle:close()
  return root ~= "" and root or nil
end

-- Get repo folder name from path
local function get_repo_name(repo_root)
  return vim.fn.fnamemodify(repo_root, ":t")
end

-- Progress window manager
local ProgressWindow = {}
ProgressWindow.__index = ProgressWindow

function ProgressWindow.new()
  local self = setmetatable({}, ProgressWindow)
  self.buf = vim.api.nvim_create_buf(false, true)
  self.lines = {}

  -- Set buffer options
  vim.bo[self.buf].bufhidden = "wipe"
  vim.bo[self.buf].filetype = "worktree-progress"

  -- Create floating window
  local width = 70
  local height = 15
  local opts = {
    relative = "editor",
    width = width,
    height = height,
    col = (vim.o.columns - width) / 2,
    row = (vim.o.lines - height) / 2,
    style = "minimal",
    border = "rounded",
    title = " Worktree Creation Progress ",
    title_pos = "center",
  }

  self.win = vim.api.nvim_open_win(self.buf, true, opts)
  vim.wo[self.win].winhl = "Normal:Normal,FloatBorder:FloatBorder"

  return self
end

function ProgressWindow:add_line(text, icon)
  icon = icon or "•"
  table.insert(self.lines, string.format("%s %s", icon, text))
  vim.api.nvim_buf_set_lines(self.buf, 0, -1, false, self.lines)

  -- Auto-scroll to bottom
  if vim.api.nvim_win_is_valid(self.win) then
    vim.api.nvim_win_set_cursor(self.win, { #self.lines, 0 })
  end
end

function ProgressWindow:update_last_line(text, icon)
  icon = icon or "•"
  if #self.lines > 0 then
    self.lines[#self.lines] = string.format("%s %s", icon, text)
    vim.api.nvim_buf_set_lines(self.buf, 0, -1, false, self.lines)
  end
end

function ProgressWindow:close()
  if vim.api.nvim_win_is_valid(self.win) then
    vim.api.nvim_win_close(self.win, true)
  end
end

-- Helper function to create worktree after checkout
local function create_worktree_step(progress, repo_root, worktree_path, branch, worktree_name)
  progress:add_line("")
  progress:add_line("Creating worktree directory...", "📁")

  -- Create parent directory first
  local parent_dir = vim.fn.fnamemodify(worktree_path, ":h")
  vim.fn.mkdir(parent_dir, "p")

  progress:update_last_line("Directory created: " .. parent_dir, "✅")
  progress:add_line("")
  progress:add_line("Creating worktree for branch: " .. branch, "🔨")

  local stderr_output = {}
  local stdout_output = {}

  -- Now create worktree with the original branch
  vim.fn.jobstart({ "git", "worktree", "add", worktree_path, branch }, {
    cwd = repo_root,
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      if data then
        vim.list_extend(stdout_output, data)
      end
    end,
    on_stderr = function(_, data)
      if data then
        vim.list_extend(stderr_output, data)
      end
    end,
    on_exit = function(_, exit_code)
      if exit_code ~= 0 then
        local error_msg = table.concat(stderr_output, "\n")
        progress:update_last_line("Failed to create worktree", "❌")
        progress:add_line("")
        progress:add_line("Error: " .. error_msg, "⚠️")
        vim.notify("Failed to create worktree", vim.log.levels.ERROR, { title = "Worktree" })
        vim.defer_fn(function()
          progress:close()
        end, 5000)
        return
      end

      progress:update_last_line("Worktree created successfully!", "✅")
      progress:add_line("")
      progress:add_line("Path: " .. worktree_path, "📍")
      progress:add_line("")
      progress:add_line("Press any key to close and copy path...", "⌨️")

      vim.notify("✓ Worktree created successfully", vim.log.levels.INFO, { title = "Worktree" })

      -- Wait for keypress then close and copy
      vim.defer_fn(function()
        if vim.api.nvim_win_is_valid(progress.win) then
          vim.api.nvim_buf_set_keymap(progress.buf, "n", "<CR>", "", {
            callback = function()
              vim.fn.setreg("+", worktree_path)
              vim.notify("Path copied to clipboard", vim.log.levels.INFO, { title = "Worktree" })
              progress:close()
            end,
          })
          vim.api.nvim_buf_set_keymap(progress.buf, "n", "q", "", {
            callback = function()
              progress:close()
            end,
          })
        end
      end, 100)
    end,
  })
end

-- Create worktree with async execution
function M.create_worktree()
  local branch = get_current_branch()

  if not branch then
    vim.notify("Not in a git repository", vim.log.levels.ERROR, { title = "Worktree" })
    return
  end

  -- Skip if on main or master
  if branch == "main" or branch == "master" then
    vim.notify("Cannot create worktree from main/master branch", vim.log.levels.WARN, { title = "Worktree" })
    return
  end

  local repo_root = get_repo_root()
  if not repo_root then
    vim.notify("Could not find git repository root", vim.log.levels.ERROR, { title = "Worktree" })
    return
  end

  local repo_name = get_repo_name(repo_root)
  local issue_number = extract_issue_number(branch)

  if not issue_number then
    vim.notify("Could not extract issue number from branch: " .. branch, vim.log.levels.ERROR, { title = "Worktree" })
    return
  end

  -- Use vim.ui.select for better UX
  vim.ui.select({ "agent", "notagent" }, {
    prompt = "Select worktree type:",
    format_item = function(item)
      return item == "agent" and "🤖 Agent (AI-assisted work)" or "👨‍💻 Manual (Regular work)"
    end,
  }, function(choice)
    if not choice then
      return
    end

    -- Create progress window
    local progress = ProgressWindow.new()

    progress:add_line("Repository: " .. repo_name, "📦")
    progress:add_line("Branch: " .. branch, "🌿")
    progress:add_line("Issue: #" .. issue_number, "🎫")
    progress:add_line("Type: " .. (choice == "agent" and "Agent" or "Manual"), "⚙️")
    progress:add_line("")

    local worktree_name = string.format("%s-%s", repo_name, issue_number)
    local worktree_path = string.format("%s/../%s/%s", repo_root, choice, worktree_name)

    -- Step 1: Checkout to main/master
    progress:add_line("Switching to main branch...", "🔄")

    local checkout_stderr = {}
    vim.fn.jobstart({ "git", "checkout", "main" }, {
      cwd = repo_root,
      stderr_buffered = true,
      on_stderr = function(_, data)
        if data then
          vim.list_extend(checkout_stderr, data)
        end
      end,
      on_exit = function(_, checkout_code)
        -- Try master if main doesn't exist
        if checkout_code ~= 0 then
          progress:update_last_line("main not found, trying master...", "🔄")

          local master_stderr = {}
          vim.fn.jobstart({ "git", "checkout", "master" }, {
            cwd = repo_root,
            stderr_buffered = true,
            on_stderr = function(_, data)
              if data then
                vim.list_extend(master_stderr, data)
              end
            end,
            on_exit = function(_, master_code)
              if master_code ~= 0 then
                progress:update_last_line("Failed to checkout main/master", "❌")
                vim.notify("Failed to checkout main or master branch", vim.log.levels.ERROR, { title = "Worktree" })
                vim.defer_fn(function()
                  progress:close()
                end, 2000)
                return
              end
              progress:update_last_line("Switched to master branch", "✅")
              create_worktree_step(progress, repo_root, worktree_path, branch, worktree_name)
            end,
          })
          return
        end

        progress:update_last_line("Switched to main branch", "✅")
        create_worktree_step(progress, repo_root, worktree_path, branch, worktree_name)
      end,
    })
  end)
end

-- List and remove worktrees
function M.list_worktrees()
  local handle = io.popen("git worktree list --porcelain 2>/dev/null")
  if not handle then
    vim.notify("Failed to list worktrees", vim.log.levels.ERROR, { title = "Worktree" })
    return
  end

  local output = handle:read("*a")
  handle:close()

  local worktrees = {}
  for path in output:gmatch("worktree ([^\n]+)") do
    local branch = output:match("worktree " .. vim.pesc(path) .. ".-branch ([^\n]+)")
    if branch and branch ~= "main" and branch ~= "master" then
      table.insert(worktrees, { path = path, branch = branch })
    end
  end

  if #worktrees == 0 then
    vim.notify("No worktrees to manage", vim.log.levels.INFO, { title = "Worktree" })
    return
  end

  vim.ui.select(worktrees, {
    prompt = "Select worktree to remove:",
    format_item = function(item)
      return string.format("%s (%s)", vim.fn.fnamemodify(item.path, ":t"), item.branch)
    end,
  }, function(choice)
    if not choice then
      return
    end

    local stderr_output = {}
    vim.fn.jobstart({ "git", "worktree", "remove", choice.path }, {
      stderr_buffered = true,
      on_stderr = function(_, data)
        if data then
          vim.list_extend(stderr_output, data)
        end
      end,
      on_exit = function(_, exit_code)
        if exit_code ~= 0 then
          local error_msg = table.concat(stderr_output, "\n")
          vim.notify(
            string.format("Failed to remove worktree\nError: %s", error_msg),
            vim.log.levels.ERROR,
            { title = "Worktree" }
          )
        else
          vim.notify("✓ Worktree removed", vim.log.levels.INFO, { title = "Worktree" })
        end
      end,
    })
  end)
end

return M
