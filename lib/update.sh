# shellcheck shell=bash
# Update all managed dependencies to their latest versions.
# Sourced by install.sh — do not execute directly.

do_update() {
  print_info "Updating all dependencies..."
  echo

  # --- Homebrew ---
  if command -v brew &>/dev/null; then
    if ${DRY_RUN}; then
      print_dry "Would run: brew update && brew upgrade"
    else
      run_with_spinner "Updating Homebrew" brew update
      run_with_spinner "Upgrading Homebrew packages" brew upgrade
    fi
  else
    print_warning "Homebrew not found — skipping"
  fi
  echo

  # --- Rust toolchain ---
  if command -v rustup &>/dev/null; then
    if ${DRY_RUN}; then
      print_dry "Would run: rustup update stable"
    else
      run_with_spinner "Updating Rust stable toolchain" rustup update stable
    fi
  else
    print_warning "rustup not found — skipping"
  fi

  if command -v cargo &>/dev/null; then
    if ${DRY_RUN}; then
      print_dry "Would run: cargo install tree-sitter-cli"
    else
      run_with_spinner "Updating tree-sitter-cli" cargo install tree-sitter-cli
    fi
  else
    print_warning "cargo not found — skipping"
  fi
  echo

  # --- Go tools ---
  if command -v go &>/dev/null; then
    if ${DRY_RUN}; then
      print_dry "Would run: go install golang.org/x/tools/gopls@latest"
    else
      run_with_spinner "Updating gopls" go install golang.org/x/tools/gopls@latest
    fi
  else
    print_warning "go not found — skipping"
  fi
  echo

  # --- Python tools ---
  if command -v uv &>/dev/null; then
    if ${DRY_RUN}; then
      print_dry "Would run: uv tool upgrade --all"
    else
      run_with_spinner "Updating uv tools (pyright, ruff, ...)" uv tool upgrade --all
    fi
  else
    print_warning "uv not found — skipping"
  fi
  echo

  # --- Scala tools ---
  if command -v cs &>/dev/null; then
    if ${DRY_RUN}; then
      print_dry "Would run: cs update metals"
    else
      run_with_spinner "Updating metals" cs update metals
    fi
  else
    print_warning "cs (coursier) not found — skipping"
  fi
  echo

  # --- Neovim plugins ---
  if command -v nvim &>/dev/null; then
    if ${DRY_RUN}; then
      print_dry "Would run: nvim --headless -c 'lua require(\"lazy\").update({ wait = true })' -c qa"
    else
      run_with_spinner "Updating neovim plugins" \
        nvim --headless -c 'lua require("lazy").update({ wait = true })' -c qa
      print_info "lazy-lock.json updated — review and commit the changes"
    fi
  else
    print_warning "nvim not found — skipping"
  fi
  echo

  # --- Fish shell (rebuild from source if outdated) ---
  local fish_bin="${HOME}/.local/bin/fish"
  if command -v cmake &>/dev/null && command -v cargo &>/dev/null; then
    local latest_tag
    latest_tag=$(curl -fsSL \
      https://api.github.com/repos/fish-shell/fish-shell/releases/latest \
      | grep '"tag_name"' \
      | sed 's/.*"tag_name": *"\([^"]*\)".*/\1/')

    if [[ -n "${latest_tag}" ]]; then
      local needs_build=true
      if command -v "${fish_bin}" &>/dev/null; then
        local current_version
        current_version=$("${fish_bin}" --version 2>/dev/null || true)
        if [[ "${current_version}" == *"${latest_tag#*-}"* ]]; then
          print_success "fish ${latest_tag} is already up to date"
          needs_build=false
        fi
      fi

      if ${needs_build}; then
        if ${DRY_RUN}; then
          print_dry "Would rebuild fish ${latest_tag} from source"
        else
          print_info "fish ${latest_tag} available — rebuilding from source..."
          do_fish
        fi
      fi
    else
      print_warning "Could not check latest fish release — skipping"
    fi
  else
    print_warning "cmake/cargo not found — skipping fish rebuild"
  fi
  echo

  # --- Fisher plugins ---
  if command -v "${fish_bin}" &>/dev/null; then
    # shellcheck disable=SC2016 # fish variable, not bash
    if ${DRY_RUN}; then
      print_dry "Would run: fisher update"
    elif "${fish_bin}" -c 'type -q fisher' 2>/dev/null; then
      run_with_spinner "Updating Fisher plugins" "${fish_bin}" -c 'fisher update'
    else
      print_warning "Fisher not installed — skipping"
    fi
  else
    print_warning "fish not found — skipping"
  fi
  echo

  # --- Fish completions (regenerate after tool upgrades) ---
  print_info "Regenerating fish shell completions..."
  generate_fish_completions
  echo

  print_success "All dependencies updated!"
}
