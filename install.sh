#!/bin/bash
#
# Bootstrap script for dotfiles on a fresh machine.
# Installs dependencies, builds fish from source, creates symlinks,
# and sets up the development environment.
#
# Each module in lib/ provides a single do_* entry point:
#   common.sh   — output helpers and spinner
#   symlink.sh  — backup, symlink creation, do_symlink, do_clean_backups
#   fisher.sh   — bootstrap_fisher (Fisher plugin manager)
#   deps.sh     — do_deps (Homebrew packages)
#   rust.sh     — do_rust (Rust toolchain)
#   lsp.sh      — do_lsp (LSP servers)
#   fish.sh     — do_fish (build fish from source)

set -uo pipefail

# Script directory (where dotfiles repo lives)
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly DOTFILES_DIR

# Source library modules
# shellcheck source=lib/common.sh
source "${DOTFILES_DIR}/lib/common.sh"
# shellcheck source=lib/fisher.sh
source "${DOTFILES_DIR}/lib/fisher.sh"
# shellcheck source=lib/symlink.sh
source "${DOTFILES_DIR}/lib/symlink.sh"
# shellcheck source=lib/deps.sh
source "${DOTFILES_DIR}/lib/deps.sh"
# shellcheck source=lib/rust.sh
source "${DOTFILES_DIR}/lib/rust.sh"
# shellcheck source=lib/lsp.sh
source "${DOTFILES_DIR}/lib/lsp.sh"
# shellcheck source=lib/fish.sh
source "${DOTFILES_DIR}/lib/fish.sh"

# Flags
DRY_RUN=false
DO_SYMLINK=false
DO_DEPS=false
DO_RUST=false
DO_LSP=false
DO_FISH=false
DO_CLEAN_BACKUPS=false

# Presents an interactive menu and sets action flags.
interactive_mode() {
  echo
  echo "Dotfiles Installation"
  echo "====================="
  echo
  echo "This script will set up your dotfiles."
  echo "Repository: ${DOTFILES_DIR}"
  echo
  echo "Options:"
  echo "  1) Install everything"
  echo "  2) Install dependencies only (Homebrew packages)"
  echo "  3) Install Rust toolchain"
  echo "  4) Install LSP servers"
  echo "  5) Build fish from source"
  echo "  6) Create symlinks only"
  echo "  7) Clean up backup files"
  echo "  8) Dry run (show what would happen)"
  echo "  9) Exit"
  echo
  read -rp "Choose an option [1-9]: " choice

  case "${choice}" in
    1) DO_DEPS=true; DO_RUST=true; DO_LSP=true
       DO_FISH=true; DO_SYMLINK=true ;;
    2) DO_DEPS=true ;;
    3) DO_RUST=true ;;
    4) DO_LSP=true ;;
    5) DO_FISH=true ;;
    6) DO_SYMLINK=true ;;
    7) DO_CLEAN_BACKUPS=true ;;
    8) DRY_RUN=true; DO_DEPS=true; DO_RUST=true
       DO_LSP=true; DO_FISH=true; DO_SYMLINK=true ;;
    9) exit 0 ;;
    *) print_error "Invalid option"; exit 1 ;;
  esac
}

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Bootstrap dotfiles on a fresh machine.

Options:
    --all             Install everything
    --deps            Install Homebrew dependencies only
    --rust            Install Rust stable toolchain
    --lsp             Install LSP servers
    --fish            Build and install fish from source
    --symlink         Create symlinks only
    --clean-backups   Remove *.backup.* files
    --dry-run         Show what would be done
    -h, --help        Show this help message

Examples:
    $(basename "$0")              # Interactive mode
    $(basename "$0") --all        # Full installation
    $(basename "$0") --symlink    # Symlinks only
    $(basename "$0") --dry-run    # Preview all changes

EOF
}

main() {
  while (( $# > 0 )); do
    case "${1}" in
      --all)
        DO_DEPS=true; DO_RUST=true; DO_LSP=true
        DO_FISH=true; DO_SYMLINK=true
        shift ;;
      --deps)          DO_DEPS=true; shift ;;
      --rust)          DO_RUST=true; shift ;;
      --lsp)           DO_LSP=true; shift ;;
      --fish)          DO_FISH=true; shift ;;
      --symlink)       DO_SYMLINK=true; shift ;;
      --clean-backups) DO_CLEAN_BACKUPS=true; shift ;;
      --dry-run)       DRY_RUN=true; shift ;;
      -h|--help)       usage; exit 0 ;;
      *)
        print_error "Unknown option: ${1}"
        usage
        exit 1 ;;
    esac
  done

  echo
  print_info "Dotfiles directory: ${DOTFILES_DIR}"
  if ${DRY_RUN}; then
    print_warning "Dry run mode — no changes will be made"
  fi
  echo

  # No flags set — run interactive mode (which sets flags)
  if ! ${DO_DEPS} && ! ${DO_RUST} && ! ${DO_LSP} \
    && ! ${DO_FISH} && ! ${DO_SYMLINK} && ! ${DO_CLEAN_BACKUPS}; then
    interactive_mode
  fi

  if ${DO_DEPS}; then do_deps; fi
  if ${DO_RUST}; then do_rust; fi
  if ${DO_LSP}; then do_lsp; fi
  if ${DO_FISH}; then do_fish; fi
  if ${DO_SYMLINK}; then do_symlink; fi
  if ${DO_CLEAN_BACKUPS}; then do_clean_backups; fi

  echo
  print_success "Done!"
}

main "$@"
