# shellcheck shell=bash
# Homebrew vulnerability audit via brew-vulns.
# Sourced by install.sh — do not execute directly.

do_audit() {
  print_info "Auditing Homebrew packages for known vulnerabilities..."
  echo

  if ! command -v brew &>/dev/null; then
    print_error "Homebrew is not installed."
    exit 1
  fi

  if ! command -v brew-vulns &>/dev/null; then
    print_error "brew-vulns is not installed. Run --deps first."
    exit 1
  fi

  if [[ ! -f "${DOTFILES_DIR}/Brewfile" ]]; then
    print_error "Brewfile not found at ${DOTFILES_DIR}/Brewfile"
    exit 1
  fi

  if ${DRY_RUN}; then
    print_dry "Would run: brew vulns --brewfile -b ${DOTFILES_DIR}/Brewfile"
    return 0
  fi

  local output
  output=$(brew vulns --brewfile -b "${DOTFILES_DIR}/Brewfile" 2>&1)

  echo "${output}"
  echo

  if echo "${output}" | grep -q "No vulnerabilities found"; then
    print_success "No vulnerabilities found!"
    return 0
  fi

  # Vulnerabilities found — upgrade affected formulae
  print_warning "Vulnerabilities detected — upgrading affected packages..."
  echo

  if brew upgrade 2>&1; then
    echo
    print_success "Packages upgraded. Re-running audit..."
    echo
    brew vulns --brewfile -b "${DOTFILES_DIR}/Brewfile" 2>&1
  else
    echo
    print_error "brew upgrade failed — some vulnerabilities may remain"
    return 1
  fi
}
