.PHONY: all deps symlink clean dry-run help

# Default target
all: deps symlink

# Install Homebrew dependencies
deps:
	@./install.sh --deps

# Create symlinks only
symlink:
	@./install.sh --symlink

# Preview what would be done
dry-run:
	@./install.sh --dry-run --all

# Remove symlinks (restore to unlinked state)
clean:
	@echo "Removing symlinks..."
	@rm -f ~/.config/fish 2>/dev/null || true
	@rm -f ~/.config/ghostty 2>/dev/null || true
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
	@echo "  all      Install everything (dependencies + symlinks)"
	@echo "  deps     Install Homebrew dependencies only"
	@echo "  symlink  Create symlinks only"
	@echo "  dry-run  Preview what would be done"
	@echo "  clean    Remove all symlinks"
	@echo "  help     Show this help message"
