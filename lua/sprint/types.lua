---@class RunnerConfig
---@field direction "float"|"horizontal"|"vertical"|"tab" Direction for the terminal window
---@field close_on_exit boolean Whether to close the terminal when the command exits
---@field size number|function Size of the terminal window
---@field keymaps RunnerKeymaps Keymap configuration
---@field palette RunnerPaletteConfig Command palette configuration
---@field float_opts table|nil Options for float terminal mode

---@class RunnerKeymaps
---@field enabled boolean Whether keymaps are enabled
---@field run_last string Keymap to run the last command
---@field open_palette string Keymap to open the command palette

---@class RunnerPaletteConfig
---@field commands RunnerCommand[] Preconfigured commands
---@field telescope_opts table|nil Options for telescope UI
---@field use_bordered_ui boolean Whether to use bordered UI for vim.ui.select fallback

---@class RunnerCommand
---@field name string Display name of the command
---@field cmd string Command to execute
---@field description string|nil Optional description
---@field icon string|nil Optional icon to display
