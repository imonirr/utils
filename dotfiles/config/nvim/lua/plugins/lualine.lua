return {
  "nvim-lualine/lualine.nvim",
  opts = function()
    local opts = {
      sections = {
        lualine_c = {
          {
            "filename",
            path = 1, -- Show relative path
          },
          {
            -- function()
            --   local pos = vim.fn.line2byte(vim.fn.line(".")) + vim.fn.col(".") - 1
            --   return "Char: " .. (pos >= 0 and pos or 0)
            -- end,

            function()
              local line = vim.fn.getline(".")
              local col = vim.fn.col(".")
              local pos = 0
              for i = 1, col - 1 do
                local char = line:sub(i, i)
                if char:match("%C") then -- Exclude non-printable characters
                  pos = pos + 1
                end
              end
              return "Char: " .. pos
            end,

            color = { fg = "#ff9e64", gui = "bold" },
          },
        },
      },
    }
    return opts
  end,
}
