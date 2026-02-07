.PHONY: all deps rust lsp fish symlink clean dry-run help

# Default target
all: deps rust lsp fish symlink

# Install Homebrew dependencies
deps:
	@./install.sh --deps

# Install Rust toolchain
rust:
	@./install.sh --rust

# Install LSP servers
lsp:
	@./install.sh --lsp

# Build fish from source
fish:
	@./install.sh --fish

# Create symlinks only
symlink:
	@./install.sh --symlink

# Preview what would be done
dry-run:
	@./install.sh --dry-run --all

# Remove symlinks (restore to unlinked state)
clean:
	@echo "Removing symlinks..."
	@rm -f ~/.config/fish/config.fish 2>/dev/null || true
	@rm -f ~/.config/fish/conf.d/rustup.fish 2>/dev/null || true
	@rm -f ~/.config/fish/functions/cat.fish 2>/dev/null || true
	@rm -f ~/.config/fish/functions/fish_greeting.fish 2>/dev/null || true
	@rm -f ~/.config/fish/fish_plugins 2>/dev/null || true
	@rm -f ~/.config/ghostty 2>/dev/null || true
	@rm -f ~/.config/git 2>/dev/null || true
	@rm -f ~/.config/nvim 2>/dev/null || true
	@rm -f ~/.gitconfig 2>/dev/null || true
	@rm -f ~/.gitattributes 2>/dev/null || true
	@rm -f ~/.commit-template.txt 2>/dev/null || true
	@echo "Done. Symlinks removed."

# Show help
help:
	@echo "Dotfiles Makefile"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  all       Install everything (deps + rust + lsp + fish + symlinks)"
	@echo "  deps      Install Homebrew dependencies"
	@echo "  rust      Install Rust stable toolchain"
	@echo "  lsp       Install LSP servers (gopls, pyright, ruff, rust-analyzer, metals)"
	@echo "  fish      Build fish from source"
	@echo "  symlink   Create symlinks only"
	@echo "  dry-run   Preview all changes"
	@echo "  clean     Remove symlinks"
	@echo "  help      Show this message"
