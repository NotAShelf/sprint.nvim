local M = {}

function M.check()
  -- Handle both new and old health check API
  local health
  if vim.health then
    health = vim.health
  else
    health = require("health")
  end

  local start = health.start or health.report_start
  local ok = health.ok or health.report_ok
  local error = health.error or health.report_error
  local info = health.info or health.report_info

  -- Start the health check report
  start("Sprint")

  -- Check for Neovim version
  if vim.fn.has('nvim-0.10.0') == 1 then
    ok("Neovim version >= 0.10.0")
  else
    error("Neovim version must be >= 0.10.0")
  end

  -- Check for dependencies
  local has_toggleterm = pcall(require, "toggleterm")
  if has_toggleterm then
    ok("toggleterm.nvim is installed")
  else
    error("toggleterm.nvim is required but not installed")
  end

  -- Check for optional dependencies
  local has_telescope = pcall(require, "telescope")
  if has_telescope then
    ok("telescope.nvim is installed (optional, enhances command palette)")
  else
    info("telescope.nvim is not installed (optional, enhances command palette)")
  end

  -- Check if config module exists and has proper functions
  local config_ok, config = pcall(require, "sprint.config")
  if config_ok then
    if type(config) == "table" then
      if type(config.setup) == "function" then
        ok("sprint.config module is correctly structured")
      else
        error("sprint.config module is missing the setup function")
      end

      if type(config.get) == "function" then
        ok("sprint.config module has get function")
      else
        error("sprint.config module is missing the get function")
      end
    else
      error("sprint.config module should return a table, got " .. type(config))
    end
  else
    error("Failed to load sprint.config module: " .. tostring(config))
  end

  -- Check if command module exists
  local command_ok, command = pcall(require, "sprint.command")
  if command_ok then
    if type(command.run) == "function" then
      ok("sprint.command module is correctly structured")
    else
      error("sprint.command module is missing the run function")
    end
  else
    error("Failed to load sprint.command module: " .. tostring(command))
  end

  -- Check if palette module exists
  local palette_ok, palette = pcall(require, "sprint.palette")
  if palette_ok then
    if type(palette.show) == "function" then
      ok("sprint.palette module is correctly structured")
    else
      error("sprint.palette module is missing the show function")
    end
  else
    error("Failed to load sprint.palette module: " .. tostring(palette))
  end
end

return M
