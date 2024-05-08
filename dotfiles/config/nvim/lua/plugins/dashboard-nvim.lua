return {
  "nvimdev/dashboard-nvim",
  opts = function(_, opts)
    table.insert(opts.config.center, {
      action = "Neorg workspace work",
      desc = "Work",
      icon = " ",
      key = "w",
    })
  end,
}
