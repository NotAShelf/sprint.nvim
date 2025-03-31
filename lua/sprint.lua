---@brief [[
--- Sprint - A command runner plugin for Neovim
--- Allows running commands in toggleterm with caching and a command palette.
---@brief ]]

-- First check if the modules load properly
local config_ok, config = pcall(require, "sprint.config")
if not config_ok then
    vim.notify("Failed to load sprint.config: " .. tostring(config), vim.log.levels.ERROR)
    return {}
end

local command_ok, command = pcall(require, "sprint.command")
if not command_ok then
    vim.notify("Failed to load sprint.command: " .. tostring(command), vim.log.levels.ERROR)
    return {}
end

local palette_ok, palette = pcall(require, "sprint.palette")
if not palette_ok then
    vim.notify("Failed to load sprint.palette: " .. tostring(palette), vim.log.levels.ERROR)
    return {}
end

local M = {}

---Run a command in toggleterm and store it as the last command
---@param cmd string Command to run
---@return boolean success Whether the command executed successfully
function M.run_command(cmd)
    return command.run(cmd)
end

---Run the last executed command
---@return boolean success Whether the last command executed successfully
function M.run_last_command()
    return command.run_last()
end

---Open the command palette
function M.open_command_palette()
    palette.show()
end

---Plugin setup function
---@param opts table|nil User configuration options
function M.setup(opts)
    -- Setup the configuration - make sure config.setup exists
    if config and type(config.setup) == "function" then
        config.setup(opts)
    else
        vim.notify("sprint.config module is missing the setup function", vim.log.levels.ERROR)
        return
    end

    -- Create user commands with Sprint namespace
    vim.api.nvim_create_user_command("Sprint", function(args)
        local subcommand = args.fargs[1]

        if subcommand == "run" then
            -- Remove the "run" subcommand from args and join the rest
            table.remove(args.fargs, 1)
            local cmd = table.concat(args.fargs, " ")
            M.run_command(cmd)
        elseif subcommand == "last" then
            M.run_last_command()
        elseif subcommand == "palette" then
            M.open_command_palette()
        else
            vim.notify("Unknown Sprint subcommand: " .. subcommand, vim.log.levels.ERROR)
        end
    end, {
        nargs = "+",
        complete = function(arglead, cmdline, cursorpos)
            local subcommands = { "run", "last", "palette" }
            if cmdline:match("^Sprint%s+$") or cmdline:match("^Sprint%s+[rlp]") then
                return vim.tbl_filter(function(cmd)
                    return cmd:match("^" .. arglead)
                end, subcommands)
            end
            return {}
        end
    })

    -- Create keymaps if enabled - safely access config
    if config and config.get and type(config.get) == "function" then
        local cfg = config.get()
        if cfg and cfg.keymaps and cfg.keymaps.enabled then
            local keymaps = cfg.keymaps
            vim.keymap.set("n", keymaps.run_last, M.run_last_command, { desc = "Run last command" })
            vim.keymap.set("n", keymaps.open_palette, M.open_command_palette, { desc = "Open command palette" })
        end
    end
end

return M
