# shellcheck shell=bash
# LSP server installation (gopls, pyright, ruff, rust-analyzer, metals).
# Sourced by install.sh — do not execute directly.

do_lsp() {
  print_info "Installing LSP servers..."
  echo

  if command -v go &>/dev/null; then
    run_with_spinner "Installing gopls" \
      go install golang.org/x/tools/gopls@latest
  else
    print_warning "go not found — skipping gopls (run --deps first)"
  fi

  if command -v uv &>/dev/null; then
    run_with_spinner "Installing pyright" uv tool install pyright
    run_with_spinner "Installing ruff" uv tool install ruff
  else
    print_warning "uv not found — skipping pyright and ruff (run --deps first)"
  fi

  if command -v rustup &>/dev/null; then
    run_with_spinner "Installing rust-analyzer" \
      rustup component add rust-analyzer
  else
    print_warning "rustup not found — skipping rust-analyzer (run --rust first)"
  fi

  if command -v cs &>/dev/null; then
    run_with_spinner "Pre-caching JDK 21 via coursier" \
      cs java-home --jvm 21
    run_with_spinner "Installing metals" cs install metals
  else
    print_warning "cs (coursier) not found — skipping metals (run --deps first)"
  fi

  echo
}
