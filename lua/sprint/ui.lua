local M = {}

---Create a bordered window for displaying selections
---@param opts table Options for the window
---@return number bufnr Buffer number
---@return number win_id Window ID
function M.create_bordered_window(opts)
  opts = opts or {}
  local width = opts.width or math.floor(vim.o.columns * 0.6)
  local height = opts.height or math.floor(vim.o.lines * 0.4)

  -- Calculate position
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_option_value('bufhidden', 'wipe', { buf = bufnr })

  -- Create window
  local win_id = vim.api.nvim_open_win(bufnr, true, {
    relative = "editor",
    row = row,
    col = col,
    width = width,
    height = height,
    style = "minimal",
    border = opts.border or "rounded",
    title = opts.title,
    title_pos = "center"
  })

  -- Set window options
  vim.api.nvim_set_option_value('winblend', opts.winblend or 0, { win = win_id })
  vim.api.nvim_set_option_value('cursorline', true, { win = win_id })

  return bufnr, win_id
end

---Create styled UI select function with borders
---@param items string[] Items to select from
---@param opts table Options for the selection
---@param on_choice function Callback function called with the selected item
function M.bordered_select(items, opts, on_choice)
  opts = opts or {}

  -- Create window and buffer
  local bufnr, win_id = M.create_bordered_window({
    title = opts.prompt or "Select an item",
    width = opts.width or math.floor(vim.o.columns * 0.6),
    height = math.min(#items + 2, math.floor(vim.o.lines * 0.4))
  })

  -- Format and set items
  local formatted_items = {}
  for i, item in ipairs(items) do
    formatted_items[i] = opts.format_item and opts.format_item(item) or item
  end

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, formatted_items)

  -- Set keymaps
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<CR>", "", {
    callback = function()
      local cursor_pos = vim.api.nvim_win_get_cursor(win_id)
      local selected_idx = cursor_pos[1]
      vim.api.nvim_win_close(win_id, true)
      if on_choice and selected_idx > 0 and selected_idx <= #items then
        on_choice(items[selected_idx])
      end
    end
  })

  vim.api.nvim_buf_set_keymap(bufnr, "n", "q", "", {
    callback = function()
      vim.api.nvim_win_close(win_id, true)
      if on_choice then
        on_choice(nil)
      end
    end
  })

  vim.api.nvim_buf_set_keymap(bufnr, "n", "<Esc>", "", {
    callback = function()
      vim.api.nvim_win_close(win_id, true)
      if on_choice then
        on_choice(nil)
      end
    end
  })

  -- Focus window
  vim.api.nvim_set_current_win(win_id)
end

return M
