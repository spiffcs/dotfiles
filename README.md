# .dotfiles

Personal configuration files.

## What's Included

| Tool | Description |
|------|-------------|
| **Neovim** | IDE-like editor with LSP, completion, Treesitter, DAP debugger |
| **Fish** | Shell with vi bindings, Tide prompt, Gruvbox theme, fzf integration |
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
./install.sh --all             # Install everything (deps + rust + LSP + fish + symlinks)
./install.sh --deps            # Install Homebrew packages only
./install.sh --rust            # Install Rust stable toolchain
./install.sh --lsp             # Install LSP servers (gopls, pyright, ruff, rust-analyzer, metals)
./install.sh --fish            # Build fish from source
./install.sh --symlink         # Create symlinks only
./install.sh --clean-backups   # Remove *.backup.* files left by previous runs
./install.sh --dry-run         # Preview changes without applying
```

### Using Make

```bash
make all             # Install everything (deps + rust + lsp + fish + symlinks)
make deps            # Install Homebrew packages
make rust            # Install Rust toolchain
make lsp             # Install LSP servers (gopls, pyright, ruff, rust-analyzer, metals)
make fish            # Build fish from source
make symlink         # Create symlinks only
make clean           # Remove symlinks
make clean-backups   # Remove *.backup.* files left by install.sh
make dry-run         # Preview changes
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

Built from source via `--fish`. Managed by [Fisher](https://github.com/jorgebucaran/fisher) with plugins declared in `fish_plugins`.

**Features:**
- [Tide](https://github.com/IlanCosman/tide) prompt with Gruvbox colors
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

## Installed Tools

Everything below is installed automatically via `make deps` (Brewfile), `make rust`, and `make lsp`.

### Core

| Tool | Description |
|------|-------------|
| [bat](https://github.com/sharkdp/bat) | `cat` clone with syntax highlighting and git integration |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder for files, history, and anything piped to it |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | Extremely fast recursive grep (powers `:Rg` in nvim) |
| [tree](https://github.com/Old-Man-Programmer/tree) | Directory listing as a tree |
| [jq](https://github.com/jqlang/jq) | JSON processor for the command line |
| [jless](https://github.com/PaulJuliusMartinez/jless) | Interactive JSON viewer in the terminal |
| [glow](https://github.com/charmbracelet/glow) | Render markdown in the terminal (also an nvim plugin) |
| [tmux](https://github.com/tmux/tmux) | Terminal multiplexer for persistent sessions |
| [wget](https://www.gnu.org/software/wget/) | HTTP file downloader |
| [coreutils](https://www.gnu.org/software/coreutils/) | GNU core utilities (gdate, greadlink, etc.) |

### System Monitoring

| Tool | Description |
|------|-------------|
| [btop](https://github.com/aristocratos/btop) | Resource monitor — CPU, memory, disks, network, processes |
| [dust](https://github.com/bootandy/dust) | Intuitive disk usage viewer (like `du` but better) |
| [ncdu](https://dev.yorhel.nl/ncdu) | Interactive disk usage analyzer with ncurses UI |
| [procs](https://github.com/dalance/procs) | Modern replacement for `ps` with color and tree view |

### Git

| Tool | Description |
|------|-------------|
| [gh](https://cli.github.com) | GitHub CLI — PRs, issues, actions, repos from the terminal |
| [git-lfs](https://git-lfs.com) | Large file storage for git |
| [git-filter-repo](https://github.com/newren/git-filter-repo) | Fast, safe history rewriting (replaces `filter-branch`) |
| [bfg](https://rtyley.github.io/bfg-repo-cleaner/) | Fast cleaner for removing secrets/large files from git history |
| [difftastic](https://github.com/Wilfred/difftastic) | Structural diff tool that understands syntax |

### Container and Supply-Chain Security

| Tool | Description |
|------|-------------|
| [dive](https://github.com/wagoodman/dive) | Explore Docker image layers and find wasted space |
| [crane](https://github.com/google/go-containerregistry/tree/main/cmd/crane) | Interact with container registries (pull, push, copy images) |
| [skopeo](https://github.com/containers/skopeo) | Inspect and copy container images between registries |
| [oras](https://oras.land) | Push and pull OCI artifacts to/from registries |
| [cosign](https://github.com/sigstore/cosign) | Sign and verify container images and artifacts |
| [grype](https://github.com/anchore/grype) | Vulnerability scanner for container images and filesystems |
| [trivy](https://github.com/aquasecurity/trivy) | Comprehensive security scanner (images, IaC, secrets) |
| [zizmor](https://github.com/woodruffw/zizmor) | GitHub Actions security linter |
| [docker-compose](https://docs.docker.com/compose/) | Multi-container orchestration |

### Languages and Runtimes

| Tool | Description |
|------|-------------|
| [go](https://go.dev) | Go programming language |
| [rustup](https://rustup.rs) | Rust toolchain installer and manager |
| [node](https://nodejs.org) | JavaScript runtime |
| [pnpm](https://pnpm.io) | Fast, disk-efficient JavaScript package manager |
| [uv](https://github.com/astral-sh/uv) | Extremely fast Python package and project manager |
| [coursier](https://get-coursier.io) | Scala/JVM artifact fetcher and launcher |

### LSP Servers and Formatters

Installed via `make lsp` and the Brewfile:

| Tool | Language | Description |
|------|----------|-------------|
| [gopls](https://pkg.go.dev/golang.org/x/tools/gopls) | Go | Official Go language server |
| [rust-analyzer](https://rust-analyzer.github.io) | Rust | Rust language server (via rustup) |
| [pyright](https://github.com/microsoft/pyright) | Python | Static type checker and language server |
| [ruff](https://github.com/astral-sh/ruff) | Python | Linter and formatter |
| [metals](https://scalameta.org/metals/) | Scala | Scala language server |
| [lua-language-server](https://github.com/LuaLS/lua-language-server) | Lua | Lua language server |
| [shellcheck](https://www.shellcheck.net) | Bash | Static analysis for shell scripts |
| [stylua](https://github.com/JohnnyMorganz/StyLua) | Lua | Opinionated Lua formatter |
| [tree-sitter](https://tree-sitter.github.io/tree-sitter/) | All | Parser generator for syntax highlighting |

### GUI Applications

| Tool | Description |
|------|-------------|
| [Ghostty](https://ghostty.org) | GPU-accelerated terminal emulator |
| [Docker Desktop](https://www.docker.com/products/docker-desktop/) | Container runtime and management UI |
| [Bruno](https://www.usebruno.com) | Offline-first API client (alternative to Postman) |
| [GIMP](https://www.gimp.org) | Image editor |
| [Rectangle](https://rectangleapp.com) | Window management via keyboard shortcuts |
| [Claude Code](https://claude.ai/claude-code) | Anthropic's AI coding assistant |

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
│   │   ├── conf.d/
│   │   │   ├── gruvbox-theme.fish   # Gruvbox color palette for fish
│   │   │   ├── tide-config.fish     # Tide prompt configuration
│   │   │   └── rustup.fish          # Rust/cargo PATH setup
│   │   ├── functions/
│   │   │   ├── cat.fish             # cat -> bat alias
│   │   │   └── fish_greeting.fish   # Custom greeting
│   │   └── fish_plugins             # Fisher plugin list
│   ├── ghostty/
│   │   └── config
│   ├── git/
│   │   └── ignore                   # Global gitignore (XDG default)
│   └── nvim/
│       ├── init.lua
│       ├── lazy-lock.json           # Plugin version lockfile
│       └── lua/
│           └── dap-config.lua       # DAP debugger setup
├── lib/                             # install.sh modules
│   ├── common.sh                    # Output helpers and spinner
│   ├── deps.sh                      # Homebrew dependency installation
│   ├── fish.sh                      # Build fish from source
│   ├── fisher.sh                    # Fisher plugin manager bootstrap
│   ├── lsp.sh                       # LSP server installation
│   ├── rust.sh                      # Rust toolchain setup
│   └── symlink.sh                   # Symlink creation and cleanup
├── .gitattributes
├── .gitconfig
├── .gitconfig.local.example         # Template for machine-specific git identity
├── .commit-template.txt
├── Brewfile
├── install.sh                       # Thin dispatcher (sources lib/*.sh)
├── sync-brewfile.sh
├── Makefile
└── README.md
```

## License

MIT
