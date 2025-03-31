local config = require("sprint.config")

local M = {}

---Last executed command
M.last_command = nil

-- Keep track of terminals created with timeout
local autoclose_timers = {}

---Run a command in toggleterm
---@param cmd string Command to run
---@param opts table|nil Optional settings to override config
---@return boolean success Whether the command was executed successfully
function M.run(cmd, opts)
  opts = opts or {}

  if not cmd or cmd == "" then
    vim.notify("No command provided", vim.log.levels.WARN)
    return false
  end

  -- Store the command as last run
  M.last_command = cmd

  -- Check if toggleterm is available
  local ok, _ = pcall(require, "toggleterm")
  if not ok then
    vim.notify("toggleterm.nvim is required but not found", vim.log.levels.ERROR)
    return false
  end

  -- Get Terminal constructor from the correct module
  local Terminal = require("toggleterm.terminal").Terminal

  -- Create and open terminal with command
  local cfg = config.get()
  local terminal_config = {
    cmd = cmd,
    direction = opts.direction or cfg.direction,
    close_on_exit = opts.close_on_exit ~= nil and opts.close_on_exit or cfg.close_on_exit,
    on_exit = function(term, job, exit_code, _)
      -- Cancel existing timer if there is one
      local timer_id = autoclose_timers[term.id]
      if timer_id then
        vim.loop.timer_stop(timer_id)
        autoclose_timers[term.id] = nil
      end
    end
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

  local term = Terminal:new(terminal_config)
  if term then
    term:toggle()
  else
    vim.notify("Failed to create terminal", vim.log.levels.ERROR)
    return false
  end

  -- Set up timeout for auto-closing
  local timeout = opts.timeout or cfg.timeout
  if timeout and type(timeout) == "number" and timeout > 0 and term then
    -- Clean up any existing timer for this terminal
    local timer_id = autoclose_timers[term.id]
    if timer_id then
      vim.loop.timer_stop(timer_id)
    end

    -- Create a new timer
    local timer = vim.loop.new_timer()
    if timer then
      autoclose_timers[term.id] = timer

      timer:start(timeout, 0, vim.schedule_wrap(function()
        if term and term:is_open() then
          vim.notify(string.format("Auto-closing terminal after %d ms timeout", timeout), vim.log.levels.INFO)
          term:close()
        end

        -- Clean up timer reference
        autoclose_timers[term.id] = nil
        if timer then
          timer:stop()
          timer:close()
        end
      end))
    end
  end

  return true
end

---Run the last command again
---@param opts table|nil Optional settings to override config
---@return boolean success Whether the last command was executed successfully
function M.run_last(opts)
  if M.last_command then
    return M.run(M.last_command, opts)
  else
    vim.notify("No previous command found", vim.log.levels.WARN)
    return false
  end
end

return M
