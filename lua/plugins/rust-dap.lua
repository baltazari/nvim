return {
  {
    "mfussenegger/nvim-dap",
    optional = true, -- only run if dap is installed
    config = function()
      local ok, dap = pcall(require, "dap")
      if not ok then
        return
      end

      -- Use codelldb installed by Mason
      local mason_path = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/"

      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
          command = mason_path .. "adapter/codelldb",
          args = { "--port", "${port}" },
        },
      }

      dap.configurations.rust = {
        {
          name = "Debug current binary",
          type = "codelldb",
          request = "launch",
          program = function()
            local cwd = vim.fn.getcwd()
            return vim.fn.input("Path to executable: ", cwd .. "/target/debug/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
          args = {},
        },
      }
    end,
  },
}
