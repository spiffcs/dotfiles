# shellcheck shell=bash
# Homebrew dependency installation.
# Sourced by install.sh — do not execute directly.

do_deps() {
  print_info "Installing Homebrew dependencies..."
  echo

  if ! command -v brew &>/dev/null; then
    print_error "Homebrew is not installed. Please install it first:"
    echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
  fi

  if [[ ! -f "${DOTFILES_DIR}/Brewfile" ]]; then
    print_error "Brewfile not found at ${DOTFILES_DIR}/Brewfile"
    exit 1
  fi

  if ${DRY_RUN}; then
    print_dry "Would install packages from ${DOTFILES_DIR}/Brewfile"
    return 0
  fi

  if brew bundle --file="${DOTFILES_DIR}/Brewfile" --no-lock --verbose; then
    echo
    print_success "All Homebrew dependencies installed!"
  else
    echo
    print_warning "Some packages failed to install."
    print_info "You can retry with: brew bundle --file=\"${DOTFILES_DIR}/Brewfile\""
  fi
  echo
}
