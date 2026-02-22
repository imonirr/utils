-- UI / Tab / Buffer management
return {
  {
    "tiagovla/scope.nvim",
    lazy = false, -- force early load
    priority = 1000,
    config = true,
  },
  {
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        mode = "buffers",
        separator_style = "slant",
        show_buffer_close_icons = false,
        show_close_icon = false,
        persist_buffer_sort = true,
        enforce_regular_tabs = false,
        show_tab_indicators = true,

        name_formatter = function(buf)
          return vim.fn.fnamemodify(buf.name, ":~:.")
        end,
        diagnostics_indicator = function(_, _, _, _)
          return ""
        end,
      },
    },
  },
}
