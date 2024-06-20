return {
  "nvimdev/dashboard-nvim",
  opts = function(_, opts)
    table.insert(opts.config.center, {
      action = "Neorg workspace work",
      desc = "Work",
      icon = "  ",
      key = "w",
      key_format = "  %s",
    })

    table.insert(opts.config.center, {
      action = "DBUI",
      desc = "Dadbod",
      icon = "*  ",
      key = "d",
      key_format = "  %s",
    })
  end,
}
