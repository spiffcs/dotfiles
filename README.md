# .dotfiles

Personal configuration files.

## What's Included

| Tool | Description |
|------|-------------|
| **Neovim** | IDE-like editor with LSP, completion, Treesitter, DAP debugger |
| **Fish** | Shell with vi bindings, uv, fzf integration |
| **Ghostty** | GPU-accelerated terminal with Gruvbox theme |
| **Git** | Aliases, commit signing, color configuration |

## Quick Start

```bash
git clone https://github.com/spiffcs/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh --all
```

## Prerequisites

- **macOS** (tested on Sonoma)
- **Homebrew** - [Install Homebrew](https://brew.sh)

## Installation

### Interactive Mode

```bash
./install.sh
```

Presents a menu to choose what to install.

### Command Line Options

```bash
./install.sh --all       # Install everything (deps + rust + LSP + fish + symlinks)
./install.sh --deps      # Install Homebrew packages only
./install.sh --rust      # Install Rust stable toolchain
./install.sh --lsp       # Install LSP servers (gopls, pyright, ruff, rust-analyzer, metals)
./install.sh --fish      # Build fish from source
./install.sh --symlink   # Create symlinks only
./install.sh --dry-run   # Preview changes without applying
```

### Using Make

```bash
make all       # Install everything (deps + rust + lsp + fish + symlinks)
make deps      # Install Homebrew packages
make rust      # Install Rust toolchain
make lsp       # Install LSP servers (gopls, pyright, ruff, rust-analyzer, metals)
make fish      # Build fish from source
make symlink   # Create symlinks only
make dry-run   # Preview changes
make clean     # Remove symlinks
```

## Configuration Details

### Neovim

Full IDE experience with plugin management via [lazy.nvim](https://github.com/folke/lazy.nvim). Uses native `vim.lsp.config()` / `vim.lsp.enable()` (nvim 0.11+).

**Plugins:**
- `gruvbox` colorscheme with `lualine` status line
- `nvim-cmp` autocompletion with LSP, buffer, and path sources
- `nvim-treesitter` for syntax highlighting and indentation
- `nvim-tree` + `fzf`/`fzf.vim` for file navigation and search
- `conform.nvim` for format-on-save, `nvim-lint` for linting
- `nvim-metals` for Scala LSP (worksheet evaluation, build import, scalafmt)
- `nvim-dap` + `nvim-dap-go` for debugging
- `todo-comments.nvim` for highlighted TODO/HACK/FIX comments
- `committia.vim` for split-view commit message editing
- `vim-better-whitespace` for trailing whitespace highlighting

**LSP Support:**
- Go (`gopls` with staticcheck)
- Scala (`metals` via [nvim-metals](https://github.com/scalameta/nvim-metals))
- Python (`pyright` for types + `ruff` for linting/formatting)
- Lua (`lua_ls`)
- Rust (`rust_analyzer`)
- R (`r_language_server`)
- OCaml (`ocamllsp`)

#### Key Mappings

Leader is `,`.

**LSP** (nvim 0.11 provides `K`, `grr`, `grn`, `gri`, `gra` by default):

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `K` | Hover docs (built-in) |
| `grr` | References (built-in) |
| `grn` | Rename (built-in) |
| `gri` | Implementation (built-in) |
| `gra` | Code action (built-in) |
| `<leader>rn` | Rename (alias) |
| `<leader>d` | Show diagnostic float |
| `[d` / `]d` | Prev/next diagnostic (built-in) |

**File Navigation:**

| Key | Action |
|-----|--------|
| `<leader>r` | Fuzzy find files (FZF) |
| `<leader>fw` | Ripgrep search (`:Rg`) |
| `<leader>n` | Focus file tree |
| `<C-n>` | Toggle file tree |
| `<C-f>` | Find current file in tree |

**Completion:**

| Key | Action |
|-----|--------|
| `<C-Space>` | Trigger completion |
| `<Tab>` / `<S-Tab>` | Cycle through items |
| `<CR>` | Confirm selection |

**Debugging (DAP):**

| Key | Action |
|-----|--------|
| `<F5>` | Start / continue |
| `<F6>` | Debug nearest Go test |
| `<F10>` | Step over |
| `<F11>` / `<F12>` | Step into / out |
| `<leader>db` | Toggle breakpoint |
| `<leader>dB` | Conditional breakpoint |

**Windows, Buffers, and Tabs:**

| Key | Action |
|-----|--------|
| `<Space>` | Search (`/`) |
| `<C-h/j/k/l>` | Navigate windows (left/down/up/right) |
| `<leader>=` | Equalize window sizes |
| `<leader>h` / `<leader>l` | Previous / next buffer |
| `<C-t>h` / `<C-t>l` | Previous / next tab |
| `<C-t>k` / `<C-t>j` | First / last tab |

**Other:**

| Key | Action |
|-----|--------|
| `gcc` | Toggle comment on line (built-in) |
| `gc` + motion | Comment selection (built-in) |
| `<leader>w` | Quick save |
| `<leader><CR>` | Clear search highlight |
| `:Glow` | Preview markdown |
| `:TodoQuickFix` | List all TODO/HACK/FIX comments |

### Fish Shell

**Features:**
- Vi key bindings enabled by default
- uv shell completions
- fzf key bindings for fuzzy search
- Custom PATH setup for Homebrew, Go, opam

**Aliases:**
- `xdg-open` -> `open` (Linux compatibility)

### Ghostty Terminal

```
Font:       FiraCode Nerd Font
Theme:      Gruvbox Dark
Cursor:     Underline
Background: #1c2022
```

**Keybindings:**
- `Shift+Enter` - Insert literal newline

### Git

**Aliases:**
| Alias | Command |
|-------|---------|
| `git l` | Pretty log with dates |
| `git s` | Short status |
| `git d` | Diff |
| `git co` | Checkout |
| `git cob` | Checkout new branch |
| `git b` | List branches by date |
| `git la` | List all aliases |

**Settings:**
- SSH commit signing enabled
- Auto whitespace fixing
- Colored output

## Manual Steps

1. **Set up Git signing:** Copy the template and fill in your identity:
   ```bash
   cp .gitconfig.local.example ~/.gitconfig.local
   ```

2. **Install additional LSP servers** not covered by `--lsp` (lua, R, OCaml):
   ```bash
   brew install lua-language-server
   ```

## File Structure

```
dotfiles/
├── .config/
│   ├── fish/
│   │   ├── config.fish
│   │   ├── conf.d/rustup.fish
│   │   ├── functions/cat.fish
│   │   ├── functions/fish_greeting.fish
│   │   └── fish_plugins
│   ├── ghostty/
│   │   └── config
│   ├── git/
│   │   └── ignore              # Global gitignore (XDG default)
│   └── nvim/
│       ├── init.lua
│       ├── lazy-lock.json      # Plugin version lockfile
│       └── lua/
│           └── dap-config.lua  # DAP debugger setup
├── .gitattributes
├── .gitconfig
├── .gitconfig.local.example    # Template for machine-specific git identity
├── .commit-template.txt
├── Brewfile
├── install.sh
├── sync-brewfile.sh
├── Makefile
└── README.md
```

## License

MIT
