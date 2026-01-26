return {
  {
    "letieu/jira.nvim",
    opts = {
      jira = {
        base = vim.env.JIRA_BASE_URL,
        email = vim.env.JIRA_EMAIL,
        token = vim.env.JIRA_API_TOKEN,
        type = "basic", -- Authentication type: "basic" (default) or "pat"
        limit = 200, -- Global limit of tasks per view (default: 200)
      },
      active_sprint_query = "project = '%s' AND assignee = currentUser() AND statusCategory != Done AND sprint in openSprints() ORDER BY updated DESC",
    },
  },
}
