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

            dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
            dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
            dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

            -- 🧠 CPPDBG adapter via cpptools (GDB backend)
            dap.adapters.cppdbg = {
                id = "cppdbg",
                type = "executable",
                command = vim.fn.stdpath "data" .. "/mason/packages/cpptools/extension/debugAdapters/bin/OpenDebugAD7",
            }

            dap.configurations.cpp = {
                {
                    name = "Launch file (GDB)",
                    type = "cppdbg",
                    request = "launch",
                    program = function() return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file") end,
                    cwd = "${workspaceFolder}",
                    stopAtEntry = true,
                    MIMode = "gdb",
                    setupCommands = {
                        {
                            description = "Enable pretty-printing for gdb",
                            text = "-enable-pretty-printing",
                            ignoreFailures = true,
                        },
                    },
                },
            }

            dap.configurations.c = dap.configurations.cpp
            dap.configurations.rust = dap.configurations.cpp
        end,
    },
}
