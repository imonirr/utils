local M = {}

local function git(args)
  local result = vim.fn.systemlist(vim.list_extend({ "git" }, args))
  if vim.v.shell_error ~= 0 or not result[1] or result[1] == "" then
    return nil
  end
  return result[1]
end

local function sanitize(name)
  return (name:gsub("[^%w%._-]", "_"))
end

-- Returns a path like <tmp>/pr_descriptions/<branch>_<repo>_PR_DESCRIPTION.md
function M.get_path()
  local branch = git({ "branch", "--show-current" }) or "detached"
  local toplevel = git({ "rev-parse", "--show-toplevel" })
  local repo = toplevel and vim.fs.basename(toplevel) or "repo"

  local dir = (vim.uv.os_tmpdir() or "/tmp") .. "/pr_descriptions"
  vim.fn.mkdir(dir, "p")

  return string.format("%s/%s_%s_PR_DESCRIPTION.md", dir, sanitize(branch), sanitize(repo))
end

return M
