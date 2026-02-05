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
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*## "; printf "Dotfiles Makefile\n\nUsage: make [target]\n\nTargets:\n"} \
		{printf "  %-10s %s\n", $$1, $$2}'
