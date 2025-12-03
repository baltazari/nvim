return {
  -- 1. Treesitter for C and C++
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "c", "cpp", "cmake" })
    end,
  },

  -- 2. Mason (updated repo: mason-org/mason.nvim)
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "clangd", -- L/C++ LSP
        "clang-format", -- formatter
        "codelldb", -- debugger
        "cpplint", -- linter
      })
    end,
  },

  -- 3. LSP configuration (clangd)
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {
          cmd = { "clangd" },
          filetypes = { "c", "cpp", "objc", "objcpp" },
          root_dir = function(fname)
            return require("lspconfig.util").root_pattern("compile_commands.json", "compile_flags.txt", ".git")(fname)
          end,
          init_options = {
            clangdFileStatus = true,
            usePlaceholders = true,
            completeUnimported = true,
            semanticHighlighting = true,
          },
        },
      },
    },
  },

  -- 4. Formatter: use conform.nvim
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.c = { "clang_format" }
      opts.formatters_by_ft.cpp = { "clang_format" }
    end,
  },

  -- 5. Linter: use nvim-lint
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.c = { "cpplint" }
      opts.linters_by_ft.cpp = { "cpplint" }
    end,
  },

  -- 6. DAP installer (debugger)
  {
    "jay-babu/mason-nvim-dap.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "codelldb" })
    end,
  },

  -- 7. DAP configuration (codelldb)
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
