return {
  -- PYRIGHT (main Python LSP)
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {
          settings = {
            python = {
              venvPath = ".",
              pythonPath = "python",
              analysis = {
                typeCheckingMode = "basic",
                autoImportCompletions = true,
              },
            },
          },
        },

        -- RUFF-LSP (linting + formatting)
        ruff_lsp = {
          on_attach = function(client, _)
            -- Disable hover from Ruff (Pyright hover is better)
            client.server_capabilities.hoverProvider = false
          end,
        },
      },
    },
  },

  -- Ruff LSP
  {
    "charliermarsh/ruff-lsp",
    ft = { "python" },
  },
}
