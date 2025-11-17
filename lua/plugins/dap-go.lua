return {
  {
    "mfussenegger/nvim-dap",
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
  },
  {
    "leoluz/nvim-dap-go",
    dependencies = {
      "mfussenegger/nvim-dap",
      "rcarriga/nvim-dap-ui",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      local dapgo = require("dap-go")

      -- Setup UI
      dapui.setup()

      -- Setup Go DAP with DWARF v4
      dapgo.setup({
        delve = {
          path = "dlv",
          build_flags = { "-gcflags=all=-dwarf=4" },
        },
      })

      -- Open/close UI automatically
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- Keymaps
      local map = vim.keymap.set
      local opts = { silent = true, noremap = true }

      map("n", "<F5>", function()
        dap.continue()
      end, vim.tbl_extend("force", opts, { desc = "DAP Continue" }))
      map("n", "<F10>", function()
        dap.step_over()
      end, vim.tbl_extend("force", opts, { desc = "DAP Step Over" }))
      map("n", "<F11>", function()
        dap.step_into()
      end, vim.tbl_extend("force", opts, { desc = "DAP Step Into" }))
      map("n", "<F12>", function()
        dap.step_out()
      end, vim.tbl_extend("force", opts, { desc = "DAP Step Out" }))

      map("n", "<leader>b", function()
        dap.toggle_breakpoint()
      end, vim.tbl_extend("force", opts, { desc = "DAP Toggle Breakpoint" }))

      map("n", "<leader>dr", function()
        dap.repl.open()
      end, vim.tbl_extend("force", opts, { desc = "DAP Open REPL" }))

      map("n", "<leader>dl", function()
        dap.run_last()
      end, vim.tbl_extend("force", opts, { desc = "DAP Run Last" }))

      -- Go-specific helpers
      map("n", "<leader>dt", function()
        dapgo.debug_test()
      end, vim.tbl_extend("force", opts, { desc = "DAP Go Debug Test" }))

      map("n", "<leader>dm", function()
        if dap.session() then
          dap.continue()
        else
          dap.continue()
        end
      end, vim.tbl_extend("force", opts, { desc = "DAP Go Debug Main" }))
    end,
  },
}
