-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations ab
-- Load pywal colors if they exist

-- Optionally, set the colorscheme to wal (if you're symlinking it)
-- vim.cmd("colorscheme wal")
-- vim.api.nvim_set_hl(0, "Comment", { italic = true })
-- vim.api.nvim_set_hl(0, "String", { italic = true })
--
local function add_italic_to_group(group)
    local hl = vim.api.nvim_get_hl(0, { name = group })
    hl.italic = true
    vim.api.nvim_set_hl(0, group, hl)
end

-- Add italics to specific groups
add_italic_to_group "Comment"
add_italic_to_group "String"
