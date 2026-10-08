local M = {}

local SEVERITY_NAMES = {
  [vim.diagnostic.severity.ERROR] = "ERROR",
  [vim.diagnostic.severity.WARN] = "WARN",
  [vim.diagnostic.severity.INFO] = "INFO",
  [vim.diagnostic.severity.HINT] = "HINT",
}

local SETTLE_MS = 1500
local TIMEOUT_MS = 10000

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = "Git Changed Diagnostics" })
end

local function git_output(root, args)
  local result = vim.system(vim.list_extend({ "git", "-C", root }, args), { text = false }):wait()
  if result.code ~= 0 then
    return nil, (result.stderr or "git command failed"):gsub("%s+$", "")
  end
  return result.stdout or ""
end

local function split_nul(output)
  local entries = {}
  for entry in output:gmatch("([^%z]+)") do
    table.insert(entries, entry)
  end
  return entries
end

local function changed_files(root)
  local tracked, tracked_error = git_output(root, { "diff", "--name-only", "-z", "HEAD", "--diff-filter=ACMR" })
  if not tracked then
    return nil, tracked_error
  end

  local untracked, untracked_error = git_output(root, { "ls-files", "--others", "--exclude-standard", "-z" })
  if not untracked then
    return nil, untracked_error
  end

  local files, seen = {}, {}
  for _, path in ipairs(vim.list_extend(split_nul(tracked), split_nul(untracked))) do
    if not seen[path] then
      seen[path] = true
      table.insert(files, path)
    end
  end
  return files
end

local function format_diagnostic(root, diagnostic)
  local filename = vim.api.nvim_buf_get_name(diagnostic.bufnr):sub(#root + 2)
  local message = diagnostic.message:gsub("\n", " ")
  local source = diagnostic.source and (" [" .. diagnostic.source .. "]") or ""
  local severity = SEVERITY_NAMES[diagnostic.severity] or "UNKNOWN"
  return string.format(
    "%s:%d:%d: %s%s: %s",
    filename,
    diagnostic.lnum + 1,
    diagnostic.col + 1,
    severity,
    source,
    message
  )
end

local function diagnostics_for(buffers)
  local diagnostics = {}
  for _, bufnr in ipairs(buffers) do
    vim.list_extend(diagnostics, vim.diagnostic.get(bufnr))
  end
  table.sort(diagnostics, function(left, right)
    local left_name = vim.api.nvim_buf_get_name(left.bufnr)
    local right_name = vim.api.nvim_buf_get_name(right.bufnr)
    if left_name ~= right_name then
      return left_name < right_name
    end
    if left.lnum ~= right.lnum then
      return left.lnum < right.lnum
    end
    return left.col < right.col
  end)
  return diagnostics
end

local function run_linters(buffers)
  local ok, lint = pcall(require, "lint")
  if not ok then
    return
  end

  for _, bufnr in ipairs(buffers) do
    vim.api.nvim_buf_call(bufnr, function()
      lint.try_lint()
    end)
  end
end

function M.collect()
  local root_result = vim.system({ "git", "rev-parse", "--show-toplevel" }, { text = true }):wait()
  if root_result.code ~= 0 then
    notify("Current directory is not in a Git repository", vim.log.levels.ERROR)
    return
  end
  local root = (root_result.stdout or ""):gsub("%s+$", "")
  local files, error_message = changed_files(root)
  if not files then
    notify(error_message, vim.log.levels.ERROR)
    return
  end
  if #files == 0 then
    vim.fn.setreg("+", "No changed files or diagnostics.")
    vim.fn.setqflist({}, "r", { title = "Git Changed Diagnostics" })
    notify("No changed files; copied an empty report")
    return
  end

  local buffers, skipped = {}, 0
  for _, relative_path in ipairs(files) do
    local path = root .. "/" .. relative_path
    local stat = vim.uv.fs_stat(path)
    if stat and stat.type == "file" then
      local bufnr = vim.fn.bufadd(path)
      vim.fn.bufload(bufnr)
      table.insert(buffers, bufnr)
    else
      skipped = skipped + 1
    end
  end

  if #buffers == 0 then
    notify("No readable changed files to diagnose", vim.log.levels.WARN)
    return
  end

  run_linters(buffers)
  local started_at = vim.uv.now()
  local last_change_at = started_at
  local group = vim.api.nvim_create_augroup("git_changed_diagnostics", { clear = true })

  vim.api.nvim_create_autocmd("DiagnosticChanged", {
    group = group,
    callback = function(event)
      if vim.tbl_contains(buffers, event.buf) then
        last_change_at = vim.uv.now()
      end
    end,
  })

  local timer = vim.uv.new_timer()
  timer:start(
    100,
    100,
    vim.schedule_wrap(function()
      local now = vim.uv.now()
      local timed_out = now - started_at >= TIMEOUT_MS
      if not timed_out and now - last_change_at < SETTLE_MS then
        return
      end

      timer:stop()
      timer:close()
      vim.api.nvim_del_augroup_by_id(group)

      local diagnostics = diagnostics_for(buffers)
      local lines = {}
      for _, diagnostic in ipairs(diagnostics) do
        table.insert(lines, format_diagnostic(root, diagnostic))
      end
      local report = #lines > 0 and table.concat(lines, "\n") or "No diagnostics in changed files."
      vim.fn.setreg("+", report)
      vim.fn.setqflist({}, "r", {
        title = "Git Changed Diagnostics",
        items = vim.diagnostic.toqflist(diagnostics),
      })
      vim.cmd("copen")

      local message = string.format("Copied %d diagnostic(s) from %d changed file(s)", #diagnostics, #buffers)
      if skipped > 0 then
        message = message .. string.format("; skipped %d non-file path(s)", skipped)
      end
      if timed_out then
        message = message .. "; timed out waiting for diagnostics, report may be incomplete"
      end
      notify(message, timed_out and vim.log.levels.WARN or vim.log.levels.INFO)
    end)
  )
end

function M.setup()
  vim.api.nvim_create_user_command("GitChangedDiagnostics", M.collect, {
    desc = "Copy diagnostics for Git-changed files",
  })
end

return M
