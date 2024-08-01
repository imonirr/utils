return {
  {
    "mfussenegger/nvim-dap",
    config = function()
      local dap = require("dap")
      dap.configurations.java = {
        {
          type = "java",
          request = "attach",
          name = "Attach to the process",
          hostName = "localhost",
          port = "5005",
        },
      }
    end,
  },
}
