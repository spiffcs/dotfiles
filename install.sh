#!/bin/bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory (where dotfiles repo lives)
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Flags
DRY_RUN=false
DO_SYMLINK=false
DO_DEPS=false

# -----------------------------------------------------------------------------
# Helper functions
# -----------------------------------------------------------------------------

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_dry() {
    echo -e "${YELLOW}[DRY-RUN]${NC} $1"
}

# -----------------------------------------------------------------------------
# Symlink functions
# -----------------------------------------------------------------------------

backup_existing() {
    local target="$1"
    if [[ -e "$target" && ! -L "$target" ]]; then
        local backup="${target}.backup.$(date +%Y%m%d%H%M%S)"
        if $DRY_RUN; then
            print_dry "Would backup: $target -> $backup"
        else
            mv "$target" "$backup"
            print_warning "Backed up existing file: $target -> $backup"
        fi
    fi
}

create_symlink() {
    local source="$1"
    local target="$2"
    local target_dir
    target_dir="$(dirname "$target")"

    # Create parent directory if needed
    if [[ ! -d "$target_dir" ]]; then
        if $DRY_RUN; then
            print_dry "Would create directory: $target_dir"
        else
            mkdir -p "$target_dir"
            print_info "Created directory: $target_dir"
        fi
    fi

    # Handle existing files/symlinks
    if [[ -L "$target" ]]; then
        local current_target
        current_target="$(readlink "$target")"
        if [[ "$current_target" == "$source" ]]; then
            print_success "Already linked: $target"
            return 0
        else
            if $DRY_RUN; then
                print_dry "Would remove existing symlink: $target -> $current_target"
            else
                rm "$target"
                print_info "Removed old symlink: $target"
            fi
        fi
    elif [[ -e "$target" ]]; then
        backup_existing "$target"
    fi

    # Create the symlink
    if $DRY_RUN; then
        print_dry "Would link: $target -> $source"
    else
        ln -s "$source" "$target"
        print_success "Linked: $target -> $source"
    fi
}

symlink_config_dir() {
    local config_name="$1"
    local source="$DOTFILES_DIR/.config/$config_name"
    local target="$HOME/.config/$config_name"

    if [[ -d "$source" ]]; then
        create_symlink "$source" "$target"
    else
        print_error "Source directory not found: $source"
        return 1
    fi
}

symlink_root_file() {
    local filename="$1"
    local source="$DOTFILES_DIR/$filename"
    local target="$HOME/$filename"

    if [[ -f "$source" ]]; then
        create_symlink "$source" "$target"
    else
        print_error "Source file not found: $source"
        return 1
    fi
}

do_symlink() {
    print_info "Creating symlinks..."
    echo

    # Ensure ~/.config exists
    if [[ ! -d "$HOME/.config" ]]; then
        if $DRY_RUN; then
            print_dry "Would create directory: $HOME/.config"
        else
            mkdir -p "$HOME/.config"
        fi
    fi

    # Symlink .config directories
    print_info "Symlinking .config directories..."
    symlink_config_dir "fish"
    symlink_config_dir "ghostty"
    symlink_config_dir "nvim"
    echo

    # Symlink root dotfiles
    print_info "Symlinking root dotfiles..."
    symlink_root_file ".gitconfig"
    symlink_root_file ".gitattributes"
    symlink_root_file ".commit-template.txt"
    echo

    print_success "Symlink setup complete!"
}

# -----------------------------------------------------------------------------
# Dependency installation
# -----------------------------------------------------------------------------

do_deps() {
    print_info "Installing Homebrew dependencies..."
    echo

    # Check if Homebrew is installed
    if ! command -v brew &> /dev/null; then
        print_error "Homebrew is not installed. Please install it first:"
        echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        exit 1
    fi

    # Install from Brewfile
    if [[ -f "$DOTFILES_DIR/Brewfile" ]]; then
        if $DRY_RUN; then
            print_dry "Would run: brew bundle --file=$DOTFILES_DIR/Brewfile"
        else
            brew bundle --file="$DOTFILES_DIR/Brewfile"
            print_success "Homebrew dependencies installed!"
        fi
    else
        print_error "Brewfile not found at $DOTFILES_DIR/Brewfile"
        exit 1
    fi
    echo
}

# -----------------------------------------------------------------------------
# Interactive mode
# -----------------------------------------------------------------------------

interactive_mode() {
    echo
    echo "Dotfiles Installation"
    echo "====================="
    echo
    echo "This script will set up your dotfiles."
    echo "Repository: $DOTFILES_DIR"
    echo
    echo "Options:"
    echo "  1) Install everything (dependencies + symlinks)"
    echo "  2) Install dependencies only (Homebrew packages)"
    echo "  3) Create symlinks only"
    echo "  4) Dry run (show what would happen)"
    echo "  5) Exit"
    echo
    read -rp "Choose an option [1-5]: " choice

    case $choice in
        1)
            do_deps
            do_symlink
            ;;
        2)
            do_deps
            ;;
        3)
            do_symlink
            ;;
        4)
            DRY_RUN=true
            do_deps
            do_symlink
            ;;
        5)
            echo "Exiting."
            exit 0
            ;;
        *)
            print_error "Invalid option"
            exit 1
            ;;
    esac
}

# -----------------------------------------------------------------------------
# Usage
# -----------------------------------------------------------------------------

usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Bootstrap dotfiles on a fresh machine.

Options:
    --all       Install everything (dependencies + symlinks)
    --deps      Install Homebrew dependencies only
    --symlink   Create symlinks only
    --dry-run   Show what would be done without making changes
    -h, --help  Show this help message

Examples:
    $(basename "$0")              # Interactive mode
    $(basename "$0") --all        # Full installation
    $(basename "$0") --symlink    # Symlinks only (if deps already installed)
    $(basename "$0") --dry-run    # Preview all changes

EOF
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --all)
                DO_DEPS=true
                DO_SYMLINK=true
                shift
                ;;
            --deps)
                DO_DEPS=true
                shift
                ;;
            --symlink)
                DO_SYMLINK=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done

    echo
    print_info "Dotfiles directory: $DOTFILES_DIR"
    if $DRY_RUN; then
        print_warning "Dry run mode - no changes will be made"
    fi
    echo

    # If no action flags specified, run interactive mode
    if ! $DO_DEPS && ! $DO_SYMLINK; then
        interactive_mode
        exit 0
    fi

    # Execute requested actions
    if $DO_DEPS; then
        do_deps
    fi

    if $DO_SYMLINK; then
        do_symlink
    fi

    echo
    print_success "Done!"
}

main "$@"
