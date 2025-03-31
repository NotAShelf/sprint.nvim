# Sprint

A streamlined command runner plugin for Neovim with command caching and a
customizable command palette. Sprint features

- The ability to cache and rerun shell commands in toggleterm
- "Pretty" command palette with preconfigured commands
- Telescope integration for enhanced command selection experience
- Full customization of terminal appearance and behavior

more features may be added as seen necessary.

## Requirements

- **Neovim 0.10+**
- **toggleterm.nvim** (required)
- telescope.nvim (optional, enhances command palette)

## Usage

### Commands

Sprint provides a single command with subcommands:

- `:Sprint run <command>` - Run a command and cache it
- `:Sprint last` - Run the last cached command
- `:Sprint palette` - Open the command palette

### Default Key Mappings

- `<leader>rl` - Run the last command
- `<leader>rp` - Open command palette

### Customizing Terminal Appearance

```lua
require('sprint').setup({
  direction = "vertical",
  size = vim.o.columns * 0.4, -- 40% of screen width
})
```

### Custom Keymappings

```lua
require('sprint').setup({
  keymaps = {
    enabled = true,
    run_last = "<leader>cr",
    open_palette = "<leader>cp",
  }
})
```

## Examples

### For a Javascript Project

```lua
require('sprint').setup({
  palette = {
    commands = {
      { name = "Install Dependencies", cmd = "npm install", description = "Install project dependencies" },
      { name = "Start Dev Server", cmd = "npm run dev", description = "Start development server" },
      { name = "Run Tests", cmd = "npm test", description = "Run test suite" },
      { name = "Build", cmd = "npm run build", description = "Build for production" },
      { name = "Lint", cmd = "npm run lint", description = "Lint with ESLint" },
      { name = "Format", cmd = "npm run format", description = "Format with Prettier" },
    }
  }
})
```

### For a Go Project

```lua
require('sprint').setup({
  palette = {
    commands = {
      { name = "Run", cmd = "go run .", description = "Run the application" },
      { name = "Test", cmd = "go test ./...", description = "Run all tests" },
      { name = "Build", cmd = "go build", description = "Build the application" },
      { name = "Install Deps", cmd = "go mod tidy", description = "Install dependencies" },
      { name = "Lint", cmd = "golangci-lint run", description = "Lint codebase" },
    }
  }
})
```

## License

Available under the [MPL 2.0](./LICENSE).
