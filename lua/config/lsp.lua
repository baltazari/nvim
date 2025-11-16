-- ======================================
--  LSP CONFIG (INCLUDING GOPLS)
--  File: lua/config/lsp.lua
-- ======================================

local lspconfig = require("lspconfig")

-- ================================
--  GO: gopls configuration
-- ================================
lspconfig.gopls.setup({
  settings = {
    gopls = {
      gofumpt = true,

      codelenses = {
        gc_details = false,
        generate = true,
        regenerate_cgo = true,
        run_govulncheck = true,
        test = true,
        tidy = true,
        upgrade_dependency = true,
        vendor = true,
      },

      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },

      analyses = {
        nilness = true,
        unusedparams = true,
        unusedwrite = true,
        useany = true,
      },

      usePlaceholders = true,
      completeUnimported = true,
      staticcheck = true,

      directoryFilters = {
        "-.git",
        "-.vscode",
        "-.idea",
        "-.vscode-test",
        "-node_modules",
      },

      semanticTokens = true,
    },
  },
})

-- ===================================================
--  Workaround: Enable semantic tokens for gopls
-- ===================================================
-- Only if Snacks is present (your config includes it)
pcall(function()
  Snacks.util.lsp.on({ name = "gopls" }, function(_, client)
    if not client.server_capabilities.semanticTokensProvider then
      local semantic = client.config.capabilities.textDocument.semanticTokens
      client.server_capabilities.semanticTokensProvider = {
        full = true,
        legend = {
          tokenTypes = semantic.tokenTypes,
          tokenModifiers = semantic.tokenModifiers,
        },
        range = true,
      }
    end
  end)
end)

-- ===================================================
--  AUTO IMPORT + AUTO FORMAT GO FILES ON SAVE
-- ===================================================

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function(args)
    local bufnr = args.buf

    -- Ensure gopls is attached to this buffer
    local clients = vim.lsp.get_active_clients({ bufnr = bufnr, name = "gopls" })
    if #clients == 0 then
      return
    end

    -- 1) Organize imports via direct LSP request
    pcall(function()
      local params = vim.lsp.util.make_range_params()
      params.context = {
        only = { "source.organizeImports" },
        diagnostics = vim.diagnostic.get(bufnr),
      }

      local result = vim.lsp.buf_request_sync(bufnr, "textDocument/codeAction", params, 1000)
      if not result then
        return
      end

      for _, res in pairs(result) do
        for _, action in pairs(res.result or {}) do
          if action.edit then
            vim.lsp.util.apply_workspace_edit(action.edit, "utf-16")
          elseif action.command then
            vim.lsp.buf.execute_command(action.command)
          end
        end
      end
    end)

    -- 2) Format the file
    pcall(function()
      vim.lsp.buf.format({ async = false })
    end)
  end,
})
