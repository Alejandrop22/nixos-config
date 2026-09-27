return {
  {
    "zbirenbaum/copilot-cmp",
    enabled = false,
  },

  {
    "zbirenbaum/copilot.lua",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = {
          enabled = true,
          auto_trigger = true,
          debounce = 75, -- no spamea requests
          keymap = {
            accept = "<C-l>",
            accept_word = "<C-j>", -- acepta solo la siguiente palabra
            accept_line = "<C-e>", -- acepta solo la línea
            next = "<M-]>", -- siguiente sugerencia
            prev = "<M-[>", -- sugerencia anterior
            dismiss = "<C-x>",
          },
        },
        panel = {
          enabled = false, -- no lo necesitas con inline activo
        },
        filetypes = {
          markdown = false,
          help = false,
          gitcommit = false,
          ["."] = false,
        },
      })
    end,
  },
}
