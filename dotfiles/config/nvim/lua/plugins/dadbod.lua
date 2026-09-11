return {
  {
    "kristijanhusak/vim-dadbod-ui",
    init = function()
      vim.g.dbs = {
        ["tca-LOCAL"] = os.getenv("TCA_LOCAL_DB_URL"),
        ["tca-NON-PROD"] = os.getenv("TCA_NON_PROD"),
        ["tca-PROD"] = os.getenv("TCA_PROD_DB_URL"),
        ["TTBS-PROD"] = os.getenv("TTBS_PROD_DB_URL"),
        ["TCA-QA-OLD"] = os.getenv("TCA_QA_OLD"),
      }

      vim.g.db_ui_save_location = "~/work/dadbod_queries"

      vim.g.db_ui_execute_on_save = false
      vim.g.db_ui_disable_mappings_dbout = 1

      vim.g.db_ui_table_helpers = {
        postgres = {
          Count = 'SELECT count(*) FROM "{schema}"."{table}"',
          DeleteTable = 'DROP TABLE "{schema}"."{table}" CASCADE',
          List = 'SELECT * from "{schema}"."{table}" LIMIT 10',
        },
      }

      -- toggle drawer width with e to max file length and to default dadbodui
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "dbui",
        callback = function(event)
          local is_expanded = false
          local original_width = nil

          vim.keymap.set("n", "e", function()
            local win = vim.api.nvim_get_current_win()

            if is_expanded then
              local target_width = original_width or vim.g.db_ui_winwidth or 30
              vim.api.nvim_win_set_width(win, target_width)
              is_expanded = false
            else
              original_width = vim.api.nvim_win_get_width(win)

              local max_len = 0
              local lines = vim.api.nvim_buf_get_lines(event.buf, 0, -1, false)
              for _, line in ipairs(lines) do
                local len = vim.fn.strdisplaywidth(line)
                if len > max_len then
                  max_len = len
                end
              end

              local target_width = math.max(max_len + 4, 30)
              vim.api.nvim_win_set_width(win, target_width)
              is_expanded = true
            end
          end, { buffer = event.buf, silent = true, desc = "Toggle DBUI sidebar width" })
        end,
      })

      -- Custom Row Inspector triggered by pressing 'R' in dbout buffers
      -- Row Inspector Function
      local function inspect_dadbod_row()
        local parent_win = vim.api.nvim_get_current_win()
        local parent_buf = vim.api.nvim_get_current_buf()
        local lines = vim.api.nvim_buf_get_lines(parent_buf, 0, -1, false)

        if #lines < 2 then
          return
        end

        local current_cursor_line = vim.api.nvim_win_get_cursor(parent_win)[1]

        local function split_cols(str)
          local cols = {}
          if str:find("\t") then
            for item in str:gmatch("[^\t]+") do
              table.insert(cols, vim.trim(item))
            end
          elseif str:find("|") then
            for item in str:gmatch("[^|]+") do
              table.insert(cols, vim.trim(item))
            end
          else
            for item in str:gmatch("%S+") do
              table.insert(cols, item)
            end
          end
          return cols
        end

        local header_line = lines[1]
        local headers = split_cols(header_line)
        if #headers == 0 then
          return
        end

        local max_h_len = 0
        for _, h in ipairs(headers) do
          if #h > max_h_len then
            max_h_len = #h
          end
        end

        -- Helper to build inspector text for a given line number
        local function build_formatted_lines(line_num)
          local line = lines[line_num]
          if not line or line == "" or line:match("^[%-%+%|%s]+$") then
            return nil
          end

          local values = split_cols(line)
          local formatted = { " Row Details (Line " .. line_num .. ")", string.rep("─", 45) }

          for i, h in ipairs(headers) do
            local val = values[i] or "<NULL>"
            table.insert(formatted, string.format(" %-" .. max_h_len .. "s : %s", h, val))
          end

          return formatted
        end

        -- Ensure initial line is valid
        if
          current_cursor_line == 1
          or lines[current_cursor_line]:match("^[%-%+%|%s]+$")
          or lines[current_cursor_line] == ""
        then
          return
        end

        local initial_formatted = build_formatted_lines(current_cursor_line)
        if not initial_formatted then
          return
        end

        -- Create buffer and window
        local float_buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(float_buf, 0, -1, false, initial_formatted)
        vim.bo[float_buf].filetype = "yaml"

        local width = math.min(90, vim.o.columns - 4)
        local height = math.min(#initial_formatted + 2, vim.o.lines - 4)

        local float_win = vim.api.nvim_open_win(float_buf, true, {
          relative = "editor",
          width = width,
          height = height,
          row = math.floor((vim.o.lines - height) / 2),
          col = math.floor((vim.o.columns - width) / 2),
          style = "minimal",
          border = "rounded",
          title = " Row Inspector (n: Next, p: Prev, q: Close) ",
          title_pos = "center",
        })

        vim.wo[float_win].wrap = true

        -- Helper to update float buffer contents and sync cursor in parent window
        local function update_row(target_line)
          if target_line < 2 or target_line > #lines then
            return
          end

          local formatted = build_formatted_lines(target_line)
          if not formatted then
            return
          end

          current_cursor_line = target_line
          vim.api.nvim_buf_set_lines(float_buf, 0, -1, false, formatted)

          -- Update cursor position in parent window so it matches current inspection row
          if vim.api.nvim_win_is_valid(parent_win) then
            vim.api.nvim_win_set_cursor(parent_win, { target_line, 0 })
          end
        end

        local opts = { buffer = float_buf, silent = true }

        -- Next row shortcut ('n')
        vim.keymap.set("n", "n", function()
          local next_line = current_cursor_line + 1
          while next_line <= #lines and (lines[next_line] == "" or lines[next_line]:match("^[%-%+%|%s]+$")) do
            next_line = next_line + 1
          end
          update_row(next_line)
        end, opts)

        -- Previous row shortcut ('p')
        vim.keymap.set("n", "p", function()
          local prev_line = current_cursor_line - 1
          while prev_line > 1 and (lines[prev_line] == "" or lines[prev_line]:match("^[%-%+%|%s]+$")) do
            prev_line = prev_line - 1
          end
          update_row(prev_line)
        end, opts)

        -- Close shortcuts
        vim.keymap.set("n", "q", "<cmd>close<cr>", opts)
        vim.keymap.set("n", "R", "<cmd>close<cr>", opts)
        vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", opts)
      end

      -- Attach mapping to BufEnter/BufWinEnter
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
        callback = function(event)
          if vim.bo[event.buf].filetype == "dbout" or vim.fn.bufname(event.buf):match("%.dbout$") then
            vim.keymap.set("n", "R", inspect_dadbod_row, {
              buffer = event.buf,
              silent = true,
              nowait = true,
              desc = "Inspect row details in float",
            })
          end
        end,
      })
    end,
  },
}
