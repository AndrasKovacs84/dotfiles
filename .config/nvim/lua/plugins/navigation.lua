return {
    {
        "folke/flash.nvim",
        event = "VeryLazy", -- Load lazily, or use "BufRead" if you prefer
        opts = {},
        -- You can set up keybindings here or in your general mappings file
    },
    {
        "chentoast/marks.nvim",
        event = "VeryLazy",
        opts = {},
    },
    -- Example Flash keybinding for jumping to characters
    vim.keymap.set({ "n", "x", "o" }, "s", function() require("flash").jump() end, { desc = "Flash Jump" }),
    vim.api.nvim_set_keymap("n", "<S-Tab>", ":bprev<CR>", { noremap = true }),
    vim.api.nvim_set_keymap("n", "<Tab>", ":bnext<CR>", { noremap = true }),
}
