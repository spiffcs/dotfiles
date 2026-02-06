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
DO_FISH=false

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

symlink_fish_config() {
    local fish_dir="$HOME/.config/fish"

    # Ensure fish config directories exist as real directories
    for dir in "$fish_dir" "$fish_dir/conf.d" "$fish_dir/functions"; do
        if [[ -L "$dir" ]]; then
            if $DRY_RUN; then
                print_dry "Would remove directory symlink: $dir"
                print_dry "Would create real directory: $dir"
            else
                rm "$dir"
                print_info "Removed directory symlink: $dir"
            fi
        fi
        if [[ ! -d "$dir" ]]; then
            if $DRY_RUN; then
                print_dry "Would create directory: $dir"
            else
                mkdir -p "$dir"
                print_info "Created directory: $dir"
            fi
        fi
    done

    # Symlink individual fish config files we own
    create_symlink "$DOTFILES_DIR/.config/fish/config.fish" "$fish_dir/config.fish"
    create_symlink "$DOTFILES_DIR/.config/fish/conf.d/rustup.fish" "$fish_dir/conf.d/rustup.fish"
    create_symlink "$DOTFILES_DIR/.config/fish/functions/cat.fish" "$fish_dir/functions/cat.fish"
    create_symlink "$DOTFILES_DIR/.config/fish/functions/fish_greeting.fish" "$fish_dir/functions/fish_greeting.fish"
    create_symlink "$DOTFILES_DIR/.config/fish/fish_plugins" "$fish_dir/fish_plugins"
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
    symlink_fish_config
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
# Build fish from source
# -----------------------------------------------------------------------------

do_fish() {
    print_info "Building fish shell from source..."
    echo

    # Check prerequisites
    local missing=()
    for cmd in cmake cargo cc; do
        if ! command -v "$cmd" &> /dev/null; then
            missing+=("$cmd")
        fi
    done
    if [[ ${#missing[@]} -gt 0 ]]; then
        print_error "Missing required tools: ${missing[*]}"
        print_info "Install cmake via Homebrew (brew install cmake) or your package manager"
        print_info "Install cargo via rustup (https://rustup.rs)"
        exit 1
    fi

    # Get latest release tag from GitHub
    print_info "Querying GitHub for latest fish release..."
    local latest_tag
    latest_tag=$(curl -fsSL https://api.github.com/repos/fish-shell/fish-shell/releases/latest | grep '"tag_name"' | sed 's/.*"tag_name": *"\([^"]*\)".*/\1/')
    if [[ -z "$latest_tag" ]]; then
        print_error "Failed to determine latest fish release tag"
        exit 1
    fi
    print_info "Latest release: $latest_tag"

    # Check if already installed at this version
    if command -v "$HOME/.local/bin/fish" &> /dev/null; then
        local current_version
        current_version=$("$HOME/.local/bin/fish" --version 2>/dev/null || true)
        if [[ "$current_version" == *"${latest_tag#*-}"* ]] 2>/dev/null; then
            print_success "fish $latest_tag is already installed at ~/.local/bin/fish"
            return 0
        fi
    fi

    if $DRY_RUN; then
        print_dry "Would clone fish-shell/fish-shell at tag $latest_tag"
        print_dry "Would build with cmake (install prefix: \$HOME/.local)"
        print_dry "Would install to ~/.local/bin/fish"
        return 0
    fi

    # Clone into a temp directory
    local build_dir
    build_dir=$(mktemp -d)
    trap "rm -rf '$build_dir'" EXIT

    print_info "Cloning fish-shell at $latest_tag into $build_dir..."
    git clone --depth 1 --branch "$latest_tag" https://github.com/fish-shell/fish-shell.git "$build_dir/fish-shell"

    # Build with cmake
    print_info "Building fish..."
    cmake -S "$build_dir/fish-shell" -B "$build_dir/fish-shell/build" \
        -DCMAKE_INSTALL_PREFIX="$HOME/.local" \
        -DCMAKE_BUILD_TYPE=Release
    cmake --build "$build_dir/fish-shell/build"

    print_info "Installing fish to ~/.local..."
    cmake --install "$build_dir/fish-shell/build"

    # Clean up (trap handles this, but be explicit)
    rm -rf "$build_dir"
    trap - EXIT

    # Verify
    if "$HOME/.local/bin/fish" --version &> /dev/null; then
        print_success "fish installed: $("$HOME/.local/bin/fish" --version)"
    else
        print_error "fish installation failed — ~/.local/bin/fish not working"
        exit 1
    fi

    # Install Fisher and plugins (reads fish_plugins)
    print_info "Installing Fisher and plugins..."
    "$HOME/.local/bin/fish" -c '
        curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
        fisher install jorgebucaran/fisher
        fisher update
    '
    print_success "Fisher and plugins installed"

    echo
    print_info "To use fish as your default shell:"
    print_info "  1. Add ~/.local/bin/fish to /etc/shells:"
    print_info "     echo \$HOME/.local/bin/fish | sudo tee -a /etc/shells"
    print_info "  2. Change your shell:"
    print_info "     chsh -s \$HOME/.local/bin/fish"
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
    echo "  1) Install everything (dependencies + fish + symlinks)"
    echo "  2) Install dependencies only (Homebrew packages)"
    echo "  3) Build fish from source"
    echo "  4) Create symlinks only"
    echo "  5) Dry run (show what would happen)"
    echo "  6) Exit"
    echo
    read -rp "Choose an option [1-6]: " choice

    case $choice in
        1)
            do_deps
            do_fish
            do_symlink
            ;;
        2)
            do_deps
            ;;
        3)
            do_fish
            ;;
        4)
            do_symlink
            ;;
        5)
            DRY_RUN=true
            do_deps
            do_fish
            do_symlink
            ;;
        6)
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
    --all       Install everything (dependencies + fish + symlinks)
    --deps      Install Homebrew dependencies only
    --fish      Build and install fish from source
    --symlink   Create symlinks only
    --dry-run   Show what would be done without making changes
    -h, --help  Show this help message

Examples:
    $(basename "$0")              # Interactive mode
    $(basename "$0") --all        # Full installation
    $(basename "$0") --fish       # Build fish from source only
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
                DO_FISH=true
                DO_SYMLINK=true
                shift
                ;;
            --deps)
                DO_DEPS=true
                shift
                ;;
            --fish)
                DO_FISH=true
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
    if ! $DO_DEPS && ! $DO_FISH && ! $DO_SYMLINK; then
        interactive_mode
        exit 0
    fi

    # Execute requested actions
    if $DO_DEPS; then
        do_deps
    fi

    if $DO_FISH; then
        do_fish
    fi

    if $DO_SYMLINK; then
        do_symlink
    fi

    echo
    print_success "Done!"
}

main "$@"
