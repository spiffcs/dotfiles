# .dotfiles

Personal configuration files.

## What's Included

| Tool | Description |
|------|-------------|
| **Neovim** | IDE-like editor with LSP, completion, Treesitter |
| **Fish** | Shell with vi bindings, pyenv, fzf integration |
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
./install.sh --all       # Install everything (deps + symlinks)
./install.sh --deps      # Install Homebrew packages only
./install.sh --symlink   # Create symlinks only
./install.sh --dry-run   # Preview changes without applying
```

### Using Make

```bash
make all       # Install everything
make deps      # Install Homebrew packages
make symlink   # Create symlinks only
make dry-run   # Preview changes
make clean     # Remove symlinks
```

## Configuration Details

### Neovim

Full IDE experience with plugin management via Packer.

**Plugins:**
- `gruvbox` colorscheme with `vim-airline` status line
- `nvim-cmp` autocompletion with LSP, buffer, and path sources
- `nvim-treesitter` for syntax highlighting
- `NERDTree` + `fzf` for file navigation
- `formatter.nvim` + `nvim-lint` for code formatting/linting

**LSP Support:**
- Go (`gopls`)
- Python (`pyright`, `ruff`)
- Lua (`lua_ls`)
- R (`r_language_server`)
- OCaml (`ocamllsp`)

**Key Mappings:**
| Key | Action |
|-----|--------|
| `<leader>n` | Open NERDTree |
| `<C-n>` | Toggle NERDTree |
| `gd` | Go to definition |
| `K` | Show hover info |
| `gr` | Go to references |
| `<leader>rn` | Rename symbol |
| `<C-Space>` | Trigger completion |

### Fish Shell

**Features:**
- Vi key bindings enabled by default
- pyenv + pyenv-virtualenv auto-initialization
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

Some things can't be automated:

1. **Change default shell to Fish:**
   ```bash
   echo $(which fish) | sudo tee -a /etc/shells
   chsh -s $(which fish)
   ```

2. **Install LSP servers:** (varies by language)
   ```bash
   # Go
   go install golang.org/x/tools/gopls@latest

   # Python
   pip install pyright ruff

   # Lua
   brew install lua-language-server
   ```

3. **Set up Git signing key:** Add your SSH key to `.gitconfig`:
   ```ini
   [user]
       signingkey =
   ```

## File Structure

```
dotfiles/
├── .config/
│   ├── fish/
│   │   ├── config.fish
│   │   └── fish_variables
│   ├── ghostty/
│   │   └── config
│   └── nvim/
│       └── init.lua
├── .gitattributes
├── .gitconfig
├── .commit-template.txt
├── Brewfile
├── install.sh
├── Makefile
└── README.md
```

## License

MIT
