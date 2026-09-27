return {

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = {}
      opts.auto_install = false
    end,
  },

  -- Mason (instala herramientas)
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {

        -- LSP
        "pyright",
        "rust-analyzer",
        "typescript-language-server",
        "eslint-lsp",
        "tailwindcss-language-server",
        "html-lsp",
        "css-lsp",
        "clangd",
        "clang-format",
        "jdtls",

        -- Formatters / linters
        "prettier",
        "black",
        "ruff",
        "stylua",
        "google-java-format",
      })
    end,
  },
}
