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

  local failed=()

  # Process explicit taps from Brewfile
  while IFS= read -r tap_name; do
    if brew tap | grep -qx "${tap_name}" 2>/dev/null; then
      printf "  ${GREEN}✔${NC} %s ${YELLOW}(already tapped)${NC}\n" "${tap_name}"
    else
      run_with_spinner "Tapping ${tap_name}" brew tap "${tap_name}" \
        || failed+=("tap: ${tap_name}")
    fi
  done < <(grep '^tap ' "${DOTFILES_DIR}/Brewfile" | sed 's/^tap *"\(.*\)"/\1/')

  # Auto-detect taps needed from third-party formula names (contain a /)
  while IFS= read -r formula; do
    local tap_name="${formula%/*}"
    if ! brew tap | grep -qx "${tap_name}" 2>/dev/null; then
      run_with_spinner "Tapping ${tap_name} (required by ${formula})" \
        brew tap "${tap_name}" \
        || failed+=("tap: ${tap_name}")
    fi
  done < <(grep '^brew ' "${DOTFILES_DIR}/Brewfile" \
    | sed 's/^brew *"\(.*\)"/\1/' | grep '/')

  # Install formulae
  while IFS= read -r formula; do
    if brew list --formula "${formula}" &>/dev/null; then
      printf "  ${GREEN}✔${NC} %s ${YELLOW}(already installed)${NC}\n" "${formula}"
    else
      run_with_spinner "Installing ${formula}" brew install "${formula}" \
        || failed+=("formula: ${formula}")
    fi
  done < <(grep '^brew ' "${DOTFILES_DIR}/Brewfile" | sed 's/^brew *"\(.*\)"/\1/')

  # Install casks
  while IFS= read -r cask; do
    if brew list --cask "${cask}" &>/dev/null; then
      printf "  ${GREEN}✔${NC} %s ${YELLOW}(already installed)${NC}\n" "${cask}"
    else
      if ! run_with_spinner "Installing ${cask} (cask)" \
        brew install --cask "${cask}"; then
        run_with_spinner "Installing ${cask} (cask, forcing overwrite)" \
          brew install --cask --force "${cask}" \
          || failed+=("cask: ${cask}")
      fi
    fi
  done < <(grep '^cask ' "${DOTFILES_DIR}/Brewfile" | sed 's/^cask *"\(.*\)"/\1/')

  echo
  if (( ${#failed[@]} > 0 )); then
    print_warning "Some packages failed to install:"
    for item in "${failed[@]}"; do
      printf "    - %s\n" "${item}"
    done
    echo
    print_info "You can retry failed packages manually or re-run: make deps"
  else
    print_success "All Homebrew dependencies installed!"
  fi
  echo
}
