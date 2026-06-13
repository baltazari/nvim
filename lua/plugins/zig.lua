return {
  -- Syntax highlighting + indentation
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "zig" } },
  },

  -- Zig Language Server (zls)
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        zls = {
          -- treat .zon files as zig too
          filetypes = { "zig", "zon" },
          -- if you want to pin/override the zls binary instead of Mason's:
          -- mason = false,
          settings = {
            zls = {
              enable_snippets = true,
              -- build-on-save diagnostics (requires a build.zig in the project)
              enable_build_on_save = true,
              -- only needed if `zig` is NOT on your PATH:
              -- zig_exe_path = "/usr/local/zig/zig",
            },
          },
        },
      },
    },
  },

  -- Optional: run `zig test` blocks from the editor
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = { "lawrence-laz/neotest-zig" },
    opts = {
      adapters = {
        ["neotest-zig"] = {},
      },
    },
  },
}
