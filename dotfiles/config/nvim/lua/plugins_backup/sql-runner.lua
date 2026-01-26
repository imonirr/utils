return {
  "tpope/vim-dadbod",
  dependencies = {
    "kristijanhusak/vim-dadbod-ui",
    "kristijanhusak/vim-dadbod-completion",
  },
  keys = {
    {
      "<leader>qr",
      function()
        local source_bufnr = vim.api.nvim_get_current_buf()
        local source_name = vim.fn.expand("%:t") ~= "" and vim.fn.expand("%:t") or "buf" .. source_bufnr
        local result_buf_name = "__DB_RESULT_" .. source_name .. "__"

        local result_bufnr = vim.fn.bufnr(result_buf_name)

        if result_bufnr == -1 then
          -- Create a new buffer and name it
          vim.cmd("belowright new")
          result_bufnr = vim.api.nvim_get_current_buf()
          vim.api.nvim_buf_set_name(result_bufnr, result_buf_name)
          vim.bo.buftype = "nofile"
          vim.bo.bufhidden = "hide"
          vim.bo.swapfile = false
          vim.bo.filetype = "sql"
        else
          -- Buffer exists: open it in a split and switch to it
          vim.cmd("belowright split")
          vim.api.nvim_set_current_buf(result_bufnr)
        end

        -- Get query from current (source) buffer
        local query_lines = vim.api.nvim_buf_get_lines(source_bufnr, 0, -1, false)
        local joined_query = table.concat(query_lines, "\n")

        -- Run it
        vim.cmd("DB " .. vim.fn.shellescape(joined_query))
      end,
      desc = "Run SQL and show per-buffer results below",
      mode = "n",
    },
  },
}
