return {
  {
    "ravitemer/mcphub.nvim",
    opts = {
      auto_approve = true,
    },
    config = function()
      require("mcphub").setup({
        port = 3000,
        config = vim.fn.expand("~/.config/mcphub/servers.json"),
        extensions = {
          copilotchat = {
            enabled = true,
            convert_tools_to_functions = true, -- Convert MCP tools to CopilotChat functions
            convert_resources_to_functions = true, -- Convert MCP resources to CopilotChat functions
            add_mcp_prefix = false, -- Add "mcp_" prefix to function names
          },
        },
      })
    end,
  },
}
