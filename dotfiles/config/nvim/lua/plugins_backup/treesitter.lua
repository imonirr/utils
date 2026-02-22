return {
  {
    "nvim-treesitter/nvim-treesitter",
    init = function()
      local ok, parsers = pcall(require, "nvim-treesitter.parsers")
      if ok and parsers and parsers.get_parser_configs then
        local parser_config = parsers.get_parser_configs()
        parser_config.bicep = {
          install_info = {
            url = "https://github.com/amaanq/tree-sitter-bicep",
            files = { "src/parser.c" },
            branch = "main",
          },
          filetype = "bicep",
        }
      end
    end,
  },
}
