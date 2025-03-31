local M = {}

-- Default configuration
---@class RunnerConfig
M.default_options = {
  direction = "float",
  close_on_exit = true,
  size = function(term)
    if term.direction == "horizontal" then
      return 15
    elseif term.direction == "vertical" then
      return vim.o.columns * 0.4
    end
  end,

  keymaps = {
    enabled = true,
    run_last = "<leader>rl",
    open_palette = "<leader>rp",
  },

  palette = {
    commands = {},
    telescope_opts = {},
    use_bordered_ui = true
  },

  float_opts = {
    border = "rounded",
    width = math.floor(vim.o.columns * 0.8),
    height = math.floor(vim.o.lines * 0.8)
  }
}

---@type RunnerConfig
M.options = vim.deepcopy(M.default_options)

---Setup function to initialize configuration
---@param opts RunnerConfig|nil User configuration options
function M.setup(opts)
  if opts then
    M.options = vim.tbl_deep_extend("force", M.default_options, opts)
  end
end

---Get the current configuration
---@return RunnerConfig Current configuration
function M.get()
  return M.options
end

return M
