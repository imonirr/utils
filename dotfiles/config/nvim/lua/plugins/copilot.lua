return {
  {
    "zbirenbaum/copilot.lua",
    opts = function()
      local enterprise_url = os.getenv("GITHUB_ENTERPRISE_URL")
      if enterprise_url then
        return {
          auth_provider_url = enterprise_url,
        }
      end
      return {}
    end,
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    keys = {
      {
        "<leader>am",
        function()
          require("CopilotChat").select_model()
        end,
        desc = "Select Model (CopilotChat)",
        mode = { "n", "x" },
      },
      {
        "<leader>as",
        function()
          vim.ui.input({ prompt = "Save chat as: " }, function(name)
            if name and name ~= "" then
              require("CopilotChat").save(name)
              vim.notify("Chat saved as: " .. name, vim.log.levels.INFO)
            end
          end)
        end,
        desc = "Save Chat (CopilotChat)",
        mode = { "n", "x" },
      },
      {
        "<leader>al",
        function()
          vim.ui.input({ prompt = "Load chat: " }, function(name)
            if name and name ~= "" then
              require("CopilotChat").load(name)
              vim.notify("Chat loaded: " .. name, vim.log.levels.INFO)
            end
          end)
        end,
        desc = "Load Chat (CopilotChat)",
        mode = { "n", "x" },
      },
    },
    opts = function()
      local enterprise_url = os.getenv("GITHUB_ENTERPRISE_URL")

      -- Common configuration
      local common_opts = {
        model = "claude-sonnet-4.5",
        mappings = {
          complete = {
            insert = "<Tab>",
          },
        },
      }

      -- If no enterprise URL, just use the built-in copilot provider
      if not enterprise_url then
        return common_opts
      end

      -- Enterprise configuration
      local function get_copilot_token()
        local config_dir
        local xdg_config = vim.fn.expand("$XDG_CONFIG_HOME")
        if xdg_config and vim.fn.isdirectory(xdg_config) > 0 then
          config_dir = xdg_config
        else
          config_dir = vim.fn.expand("~/.config")
        end

        local target_host = enterprise_url:gsub("^https?://", "")

        for _, filename in ipairs({ "hosts.json", "apps.json" }) do
          local token_file = config_dir .. "/github-copilot/" .. filename
          if vim.fn.filereadable(token_file) == 1 then
            local file = io.open(token_file, "r")
            if file then
              local content = file:read("*a")
              file:close()
              local data = vim.json.decode(content)

              if data then
                for key, v in pairs(data) do
                  if v.oauth_token and key:find(target_host, 1, true) then
                    return v.oauth_token
                  end
                end
              end
            end
          end
        end

        error("No GitHub Copilot token found for " .. target_host)
      end

      return vim.tbl_deep_extend("force", common_opts, {
        provider = "enterprise_copilot",
        providers = {
          copilot = { disabled = true },
          enterprise_copilot = {
            get_headers = function()
              local token = get_copilot_token()
              local curl = require("CopilotChat.utils.curl")

              local response, err = curl.get(enterprise_url .. "/api/v3/copilot_internal/v2/token", {
                json_response = true,
                headers = {
                  ["Authorization"] = "Token " .. token,
                },
              })

              if err then
                error(err)
              end

              local endpoints_api = response.body.endpoints and response.body.endpoints.api
              if not endpoints_api then
                error("Missing endpoints.api in response")
              end

              _G._copilot_enterprise_api = endpoints_api

              return {
                ["Authorization"] = "Bearer " .. response.body.token,
                ["Editor-Version"] = "Neovim/"
                  .. vim.version().major
                  .. "."
                  .. vim.version().minor
                  .. "."
                  .. vim.version().patch,
                ["Editor-Plugin-Version"] = "CopilotChat.nvim/*",
                ["Copilot-Integration-Id"] = "vscode-chat",
              },
                response.body.expires_at
            end,

            get_models = function(headers)
              local curl = require("CopilotChat.utils.curl")
              local response, err = curl.get(_G._copilot_enterprise_api .. "/models", {
                json_response = true,
                headers = headers,
              })

              if err then
                error(err)
              end

              return vim
                .iter(response.body.data)
                :filter(function(model)
                  return model.capabilities.type == "chat" and model.model_picker_enabled
                end)
                :map(function(model)
                  return {
                    id = model.id,
                    name = model.name,
                    tokenizer = model.capabilities.tokenizer,
                    max_input_tokens = model.capabilities.limits.max_prompt_tokens,
                    max_output_tokens = model.capabilities.limits.max_output_tokens,
                    streaming = model.capabilities.supports.streaming,
                    tools = model.capabilities.supports.tool_calls,
                    version = model.version,
                  }
                end)
                :totable()
            end,

            prepare_input = require("CopilotChat.config.providers").copilot.prepare_input,
            prepare_output = require("CopilotChat.config.providers").copilot.prepare_output,

            get_url = function()
              return _G._copilot_enterprise_api .. "/chat/completions"
            end,
          },
        },
      })
    end,
  },
}
