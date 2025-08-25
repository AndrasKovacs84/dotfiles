return {
    -- Core DAP plugin
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "rcarriga/nvim-dap-ui",
            "theHamsta/nvim-dap-virtual-text",
        },
        config = function()
            local dap = require "dap"
            local dapui = require "dapui"

            dapui.setup()
            require("nvim-dap-virtual-text").setup {}

            -- Optional UI open/close on start/stop
            dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
            dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
            dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

            local codelldb_path = vim.fn.expand "~/.local/share/nvim/mason/packages/codelldb/extension/adapter/codelldb"
            local liblldb_path =
                vim.fn.expand "~/.local/share/nvim/mason/packages/codelldb/extension/lldb/lib/liblldb.so"

            vim.fn.setenv("DAP_LOG_FILE", "/tmp/dap.log")
            vim.fn.setenv("DAP_VERBOSE", "1")
            dap.adapters.codelldb = {
                type = "server",
                port = "13000",
                executable = {
                    command = codelldb_path,
                    args = { "--liblldb", liblldb_path, "--port", "13000" },
                },
            }

            dap.configurations.cpp = {
                {
                    name = "Launch file",
                    type = "codelldb",
                    request = "launch",
                    program = function() return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file") end,
                    cwd = "${workspaceFolder}",
                    stopOnEntry = true,
                    args = {},
                    setupCommands = {
                        {
                            text = "settings set target.load-cwd-lldbinit false",
                        },
                        {
                            text = "settings set symbols.enable-external-lookup false",
                        },
                        {
                            text = "settings set target.source-map /usr/src/debug /dev/null",
                        },
                    },
                },
            }
            -- You can also use the same config for C and Rust
            dap.configurations.c = dap.configurations.cpp
            dap.configurations.rust = dap.configurations.cpp
        end,
    },
}
