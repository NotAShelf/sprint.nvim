local config = require("sprint.config")

local M = {}

---Last executed command
M.last_command = nil

---Run a command in toggleterm
---@param cmd string Command to run
---@return boolean success Whether the command was executed successfully
function M.run(cmd)
  if not cmd or cmd == "" then
    vim.notify("No command provided", vim.log.levels.WARN)
    return false
  end

  -- Store the command as last run
  M.last_command = cmd

  -- Check if toggleterm is available
  local ok, toggleterm = pcall(require, "toggleterm")
  if not ok then
    vim.notify("toggleterm.nvim is required but not found", vim.log.levels.ERROR)
    return false
  end

  -- Create and open terminal with command
  local cfg = config.get()
  local terminal_config = {
    cmd = cmd,
    direction = cfg.direction,
    close_on_exit = cfg.close_on_exit
  }

  -- Size configuration
  if type(cfg.size) == "function" then
    terminal_config.size = cfg.size
  elseif type(cfg.size) == "number" then
    terminal_config.size = cfg.size
  end

  -- Add float options if applicable
  if cfg.direction == "float" and cfg.float_opts then
    terminal_config.float_opts = cfg.float_opts
  end

  local term = toggleterm.Terminal:new(terminal_config)
  term:toggle()

  return true
end

---Run the last command again
---@return boolean success Whether the last command was executed successfully
function M.run_last()
  if M.last_command then
    return M.run(M.last_command)
  else
    vim.notify("No previous command found", vim.log.levels.WARN)
    return false
  end
end

return M
