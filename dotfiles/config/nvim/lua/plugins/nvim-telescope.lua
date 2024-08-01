return {
  "nvim-telescope/telescope.nvim",
  -- change some options
  opts = {
    defaults = {
      file_ignore_patterns = {
        -- ignore dotnet generated folders in the file search
        "^target/",
        "/target/",
      },
    },
  },
}
