#!/bin/bash
set -euo pipefail

# Regenerate Brewfile from currently installed Homebrew packages.
# Run this after installing or removing packages to keep the Brewfile in sync.

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BREWFILE="$DOTFILES_DIR/Brewfile"

if ! command -v brew &> /dev/null; then
    echo "Error: Homebrew is not installed." >&2
    exit 1
fi

echo "Generating Brewfile from installed packages..."

{
    echo "# Brewfile - Declarative Homebrew dependencies"
    echo "# Install with: brew bundle"
    echo "# Update with: ./sync-brewfile.sh"
    echo

    # Formulae (top-level only, skip auto-installed dependencies)
    for pkg in $(brew leaves | sort); do
        echo "brew \"$pkg\""
    done

    echo

    # Casks
    for cask in $(brew list --cask | sort); do
        echo "cask \"$cask\""
    done
} > "$BREWFILE"

echo "Wrote $BREWFILE"
echo
echo "Review the diff before committing:"
echo "  git diff Brewfile"
