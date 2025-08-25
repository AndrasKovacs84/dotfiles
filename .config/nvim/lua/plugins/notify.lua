return {
    {
        "rcarriga/nvim-notify",
        config = function()
            require("notify").setup {
                timeout = 8000,
                stages = "fade",
                render = "default",
                top_down = true,
            }
            vim.notify = require "notify"
        end,
    },
}
