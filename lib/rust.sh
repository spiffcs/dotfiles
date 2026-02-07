# shellcheck shell=bash
# Rust toolchain installation via rustup.
# Sourced by install.sh — do not execute directly.

do_rust() {
  print_info "Setting up Rust toolchain..."
  echo

  if ! command -v rustup &>/dev/null; then
    print_error "rustup is not installed. Run --deps first to install it via Homebrew."
    exit 1
  fi

  if rustup toolchain list 2>/dev/null | grep -q 'stable'; then
    print_success "Rust stable toolchain already installed"
    run_with_spinner "Updating Rust stable toolchain" rustup update stable
  else
    run_with_spinner "Installing Rust stable toolchain" \
      rustup toolchain install stable
    if ${DRY_RUN}; then
      print_dry "Would run: rustup default stable"
    else
      rustup default stable
    fi
  fi

  # tree-sitter CLI is needed by nvim-treesitter to compile parsers
  run_with_spinner "Installing tree-sitter-cli" cargo install tree-sitter-cli
  echo
}
