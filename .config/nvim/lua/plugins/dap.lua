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
            require("nvim-dap-virtual-text").setup()

            -- Optional UI open/close on start/stop
            dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
            dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
            dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

            -- Find Mason install path of codelldb
            local mason_registry = require "mason-registry"
            local codelldb = mason_registry.get_package "codelldb"
            local extension_path = codelldb:get_install_path() .. "/extension/lldb/bin/lldb"
            print(vim.inspect(extension_path))
            local codelldb_path = extension_path .. "adapter/codelldb"
            local liblldb_path = extension_path .. "lldb/lib/liblldb.so" -- for Linux (adjust for Mac/Windows) Add your DAP config for GDB (cppdbg) here, or in another file
            dap.adapters.codelldb = {
                type = "server",
                port = "${port}",
                executable = {
                    command = codelldb_path,
                    args = { "--port", "${port}" },
                    -- On Windows you may need to set env vars here
                },
            }

            dap.configurations.cpp = {
                {
                    name = "Launch file",
                    type = "codelldb",
                    request = "launch",
                    program = function() return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file") end,
                    cwd = "${workspaceFolder}",
                    stopOnEntry = false,
                    args = {},
                },
            }
            -- You can also use the same config for C and Rust
            dap.configurations.c = dap.configurations.cpp
            dap.configurations.rust = dap.configurations.cpp
        end,
    },
}
