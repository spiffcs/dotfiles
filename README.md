# .dotfiles

## Neovim Configuration (.config/nvim/init.lua)

This is my personal Neovim configuration. It's designed for a smooth development experience across various programming languages and tools. It includes settings for general usability, language server protocol (LSP) integration, syntax highlighting, code completion, formatting, and various plugins. The following is not yet covered in this readme: `.config/ghostty` and `.config/fish` files.

## Features

- **Plugin Management**: Managed with [Packer.nvim](https://github.com/wbthomason/packer.nvim).
- **UI Enhancements**: Custom colorscheme, UI plugins like `vim-airline`, `NERDTree`.
- **LSP & Autocompletion**: LSP configuration for Go, R, Lua, Python, and other languages with nvim-cmp for autocompletion.
- **Code Formatting & Linting**: Integration with `formatter.nvim` and `nvim-lint` for automatic code formatting and linting.
- **Syntax Highlighting**: Powered by [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) for robust syntax highlighting.
- **File Navigation**: `NERDTree` for file exploration and `fzf` for fuzzy searching.

## Setup

### Prerequisites

- **Neovim 0.5+**: Ensure you are using Neovim version 0.5 or later.
- **Git**: Required for plugin management via Packer.

### Install Packer

This setup uses [Packer.nvim](https://github.com/wbthomason/packer.nvim) for managing plugins. If you don't have Packer installed, the configuration will handle the installation automatically.

## Key Features Breakdown

### Plugins

This configuration includes the following categories of plugins:

- **UI**:
    - `gruvbox`: A popular colorscheme.
    - `vim-airline`: A status line plugin for Neovim.
    - `vim-airline-themes`: Themes for vim-airline.
    - `ntpeters/vim-better-whitespace`: Highlights trailing whitespace.
  
- **Completion**:
    - `nvim-lspconfig`: LSP (Language Server Protocol) configurations.
    - `nvim-cmp`: Autocompletion framework.
    - `cmp-nvim-lsp`, `cmp-buffer`, `cmp-path`, `cmp-cmdline`: Various completion sources for LSP, buffers, paths, and command-line.
  
- **Search**:
    - `fzf`: A command-line fuzzy finder.
  
- **Code**:
    - `nvim-treesitter`: Syntax highlighting and more.
    - `vim-go`: Go programming support.
    - `R.nvim`: R programming support.
    - `Comment.nvim`: Toggle comments.
    - `copilot.vim`: GitHub Copilot support.
  
- **Formatting & Linting**:
    - `formatter.nvim`: Code formatter for various languages.
    - `nvim-lint`: Linting support for different file types.

- **Not Covered; Installed Separate**
    - `ocamllsp`: LSP Managed Separate
    - `lua_ls`: LSP Managed Separate
    - `gopls`: LSP Managed Separate (vim-go might do this now?)
    - `r_language_server`: LSP Managed Separate
    - Code Formatters Managed Separate


### LSP Configuration

The configuration supports LSP for multiple programming languages. Here's a quick rundown:

- **Go**: `gopls` LSP setup with formatting on save.
- **R**: `r_language_server` LSP for R
- **Lua**: Using `lua_ls` for Lua LSP, with custom configurations for Neovim.
- **OCaml**: `ocamllsp` for OCaml language support.

### Autocompletion

The configuration includes autocompletion using `nvim-cmp`, with completion sources from:

- LSP servers
- Buffers
- File paths
- Command-line

Key mappings for autocompletion:
- `<C-Space>`: Trigger autocompletion.
- `<CR>`: Confirm autocompletion.
- `<TAB>` && `<S-TAB>`: cycle auto completion.

Key mappings for copilot:
- `<leader>c`: trigger Copilot completion
- `<leader>a`: accept Copilot completion

### Formatting & Linting

- **Formatting**: Auto-formatting is set up with `formatter.nvim` and `nvim-lint`.
  - Go, Lua, and R files are formatted automatically on save.
  - Users need to install ecosystem specific formatters
- **Linting**: Linting is powered by `nvim-lint`, with configurations for Lua files using `luacheck`.

### Language-Specific Indentation

The config automatically sets indentation rules based on file types. For example:

- **Lua**: 2 spaces (spaces enabled)
- **Python**: 4 spaces (spaces enabled)
- **Makefiles**: 4 spaces (tabs enabled)
- **Go**: 4 spaces (tabs enabled)
- **r**: 2 spaces (spaces enabled)

### Key Mappings

Several custom key mappings have been set up for quick access to various features:

- **File Navigation**:
    - `<leader>n`: Open NERDTree.
    - `<C-n>`: Toggle NERDTree.
    - `<C-f>`: Focus NERDTree on the current file.
  
- **LSP**:
    - `gd`: Go to definition.
    - `K`: Show hover info.
    - `gr`: Go to references.
    - `<leader>rn`: Rename symbol.
  
- **Diagnostic**:
    - `<leader>d`: Open diagnostic floating window.
    - `[d` and `]d`: Navigate to previous and next diagnostic.

- **Window Management**:
    - `<C-h>`, `<C-j>`, `<C-k>`, `<C-l>`: Move between split windows.
    - `<leader>h`, `<leader>l`: Switch between buffers.

### Visual Enhancements
- **Colors**: Uses `gruvbox` as the primary color scheme with `vim-airline` for the status line.
- **Fonts**: The setup assumes you're using a terminal with support for true color (e.g., `termguicolors` enabled).
  
### General Settings
- **History**: `500` lines of command history.
- **Autoread**: Automatically read files when modified outside of Neovim.
- **Line Numbers**: Relative and absolute line numbers.
- **Mouse**: Enabled in normal and visual modes (`mouse = "nv"`).
