return {
  "rcarriga/nvim-dap-ui",
  config = function(_, opts)
    local dapui = require("dapui")

    opts = vim.tbl_deep_extend("force", opts, {
      layouts = {
        {
          elements = {
            "scopes",
            "breakpoints",
            "watches",
          },
          size = 40,
          position = "left",
        },
      },
    })
    dapui.setup(opts)
  end,
}
