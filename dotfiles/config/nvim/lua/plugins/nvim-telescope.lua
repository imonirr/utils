return {
  "nvim-telescope/telescope.nvim",
  -- change some options
  opts = {
    defaults = {
      path_display = { "smart" },
      file_ignore_patterns = {
        -- ignore dotnet generated folders in the file search
        "^target/",
        "/target/",
      },
    },
  },
}
