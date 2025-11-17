return {
  {
    "mfussenegger/nvim-dap",
    optional = true, -- only run if dap is already loaded
    config = function()
      local ok, dap = pcall(require, "dap")
      if not ok then
        return
      end

      -- Simple codelldb adapter (expects "codelldb" in PATH)
      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
          command = "codelldb", -- command name
          args = { "--port", "${port}" },
        },
      }

      -- Rust debug config
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
