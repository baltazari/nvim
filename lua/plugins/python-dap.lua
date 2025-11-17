return {
  {
    "mfussenegger/nvim-dap",
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dapui.setup()

      dap.listeners.after.event_initialized["dapui"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui"] = function()
        dapui.close()
      end

      -- Python debugging setup
      dap.adapters.python = {
        type = "executable",
        command = "python",
        args = { "-m", "debugpy.adapter" },
      }

      dap.configurations.python = {
        {
          type = "python",
          request = "launch",
          name = "Launch File",
          program = "${file}",
          console = "integratedTerminal",
        },
      }

      -- keymaps
      local map = vim.keymap.set
      map("n", "<F5>", dap.continue, { desc = "Continue" })
      map("n", "<F10>", dap.step_over, { desc = "Step Over" })
      map("n", "<F11>", dap.step_into, { desc = "Step Into" })
      map("n", "<F12>", dap.step_out, { desc = "Step Out" })
      map("n", "<leader>b", dap.toggle_breakpoint, { desc = "Toggle Breakpoint" })
      map("n", "<leader>dr", dap.repl.open, { desc = "Open REPL" })
    end,
  },
}
