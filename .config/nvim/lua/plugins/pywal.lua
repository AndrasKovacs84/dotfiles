
return {
  {
    "AlphaTechnolog/pywal.nvim",
    as = "pywal",
    lazy = false,
    priority = 1000,
    config = function()
      require("pywal").setup()
      vim.cmd("colorscheme pywal")
    end,
  },
}
