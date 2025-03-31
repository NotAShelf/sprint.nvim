local config = require("sprint.config")
local command = require("sprint.command")
local ui = require("sprint.ui")

local M = {}

---Show command palette using telescope if available, otherwise use vim.ui.select
function M.show()
  local cfg = config.get()
  local commands = cfg.palette.commands

  -- Check if there are any commands
  if not commands or #commands == 0 then
    vim.notify("No commands defined in palette", vim.log.levels.WARN)
    return
  end

  -- Try to use telescope if available
  local ok, _ = pcall(require, "telescope.builtin")
  if ok then
    return M.show_telescope_picker()
  end

  -- Fallback to Sprint UI or vim.ui.select
  if cfg.palette.use_bordered_ui then
    return M.show_bordered_ui()
  else
    return M.show_default_ui()
  end
end

---Show command palette
function M.show_bordered_ui()
  local cfg = config.get()
  local commands = cfg.palette.commands

  -- Extract names
  local items = {}
  for i, cmd in ipairs(commands) do
    items[i] = cmd.name
  end

  -- Show bordered select UI
  ui.bordered_select(items, {
    prompt = "Select command to run",
    format_item = function(item)
      -- Find the command object that matches this name
      for _, cmd in ipairs(commands) do
        if cmd.name == item then
          if cmd.description then
            return string.format("%s - %s", cmd.name, cmd.description)
          else
            return cmd.name
          end
        end
      end
      return item
    end
  }, function(choice)
    if not choice then return end

    -- Find the command that matches the selection
    for _, cmd in ipairs(commands) do
      if cmd.name == choice then
        command.run(cmd.cmd)
        break
      end
    end
  end)
end

---Show command palette with default vim.ui.select
function M.show_default_ui()
  local cfg = config.get()
  local commands = cfg.palette.commands

  local items = {}
  local command_map = {}

  for i, cmd_item in ipairs(commands) do
    local display = cmd_item.name
    items[i] = display
    command_map[display] = cmd_item.cmd
  end

  vim.ui.select(items, {
    prompt = "Select command to run:",
    format_item = function(item)
      for _, cmd in ipairs(commands) do
        if cmd.name == item then
          if cmd.description then
            return string.format("%s - %s", cmd.name, cmd.description)
          else
            return item
          end
        end
      end
      return item
    end,
  }, function(choice)
    if choice then
      command.run(command_map[choice])
    end
  end)
end

---Show command palette with telescope
function M.show_telescope_picker()
  local cfg = config.get()
  local commands = cfg.palette.commands
  local telescope_opts = cfg.palette.telescope_opts or {}

  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  -- Create finder
  local finder_opts = {
    results = commands,
    entry_maker = function(entry)
      return {
        value = entry,
        display = entry.name,
        ordinal = entry.name,
        -- Show description in the preview area
        preview_command = function(entry, bufnr)
          if entry.value.description then
            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
              "Command: " .. entry.value.cmd,
              "",
              "Description: " .. entry.value.description
            })
          else
            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
              "Command: " .. entry.value.cmd
            })
          end
        end
      }
    end,
  }

  pickers.new(telescope_opts, {
    prompt_title = "Command Palette",
    finder = finders.new_table(finder_opts),
    sorter = conf.generic_sorter(telescope_opts),
    previewer = conf.qflist_previewer(telescope_opts),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          command.run(selection.value.cmd)
        end
      end)
      return true
    end,
  }):find()
end

return M
