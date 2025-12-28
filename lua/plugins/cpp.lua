return {
  -- 1. Treesitter: syntax highlight for C/C++
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "c", "cpp", "cmake" })
    end,
  },

  -- 2. Mason: install LSP, formatter, debugger, linter
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "clangd", -- C/C++ LSP
        "clang-format", -- formatter
        "codelldb", -- debugger
        "cpplint", -- linter
      })
    end,
  },

  -- 3. LSP config: clangd
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local util = require("lspconfig.util")

      opts.servers = opts.servers or {}

      opts.servers.clangd = {
        cmd = { "clangd" },
        filetypes = { "c", "cpp", "objc", "objcpp" },
        root_dir = function(fname)
          -- Try to detect project root by common files, then fall back to folder
          return util.root_pattern("compile_commands.json", "compile_flags.txt", ".git")(fname)
            or util.path.dirname(fname)
        end,
        init_options = {
          clangdFileStatus = true,
          usePlaceholders = true,
          completeUnimported = true,
          semanticHighlighting = true,
        },
      }
    end,
  },

  -- 4. Formatter: conform.nvim with clang-format
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.c = { "clang-format" }
      opts.formatters_by_ft.cpp = { "clang-format" }
    end,
  },

  -- 5. Linter: nvim-lint with cpplint
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.c = { "cpplint" }
      opts.linters_by_ft.cpp = { "cpplint" }
    end,
  },

  -- 6. Debugger: configure codelldb (optional but nice)
  {
    "mfussenegger/nvim-dap",
    config = function()
      local dap = require("dap")
      local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/codelldb"

      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
          command = mason_bin,
          args = { "--port", "${port}" },
        },
      }

      dap.configurations.cpp = {
        {
          name = "Launch C/C++ file",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
      }

      dap.configurations.c = dap.configurations.cpp
    end,
  },
}
