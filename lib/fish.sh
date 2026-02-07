# shellcheck shell=bash
# Fish shell: build from source and login shell setup.
# Sourced by install.sh — do not execute directly.

# Builds fish from source (if needed) and bootstraps Fisher, plugins,
# and login shell configuration.
do_fish() {
  print_info "Building fish shell from source..."
  echo

  local missing=()
  local cmd
  for cmd in cmake cargo cc; do
    command -v "${cmd}" &>/dev/null || missing+=("${cmd}")
  done
  if (( ${#missing[@]} > 0 )); then
    print_error "Missing required tools: ${missing[*]}"
    exit 1
  fi

  # Get latest release tag from GitHub
  print_info "Querying GitHub for latest fish release..."
  local latest_tag
  latest_tag=$(curl -fsSL \
    https://api.github.com/repos/fish-shell/fish-shell/releases/latest \
    | grep '"tag_name"' \
    | sed 's/.*"tag_name": *"\([^"]*\)".*/\1/')
  if [[ -z "${latest_tag}" ]]; then
    print_error "Failed to determine latest fish release tag"
    exit 1
  fi
  print_info "Latest release: ${latest_tag}"

  # --- Build phase (skipped if already at latest version) ---
  local needs_build=true
  if command -v "${HOME}/.local/bin/fish" &>/dev/null; then
    local current_version
    current_version=$("${HOME}/.local/bin/fish" --version 2>/dev/null || true)
    if [[ "${current_version}" == *"${latest_tag#*-}"* ]]; then
      print_success "fish ${latest_tag} is already installed"
      needs_build=false
    fi
  fi

  if ${needs_build}; then
    if ${DRY_RUN}; then
      print_dry "Would build and install fish ${latest_tag} to ~/.local"
    else
      local build_dir
      build_dir=$(mktemp -d)
      # shellcheck disable=SC2064 # Intentional: expand build_dir now
      trap "rm -rf '${build_dir}'" EXIT

      run_with_spinner "Cloning fish-shell at ${latest_tag}" \
        git clone --depth 1 --branch "${latest_tag}" \
          https://github.com/fish-shell/fish-shell.git \
          "${build_dir}/fish-shell"
      run_with_spinner "Configuring fish build" \
        cmake -S "${build_dir}/fish-shell" \
          -B "${build_dir}/fish-shell/build" \
          -DCMAKE_INSTALL_PREFIX="${HOME}/.local" \
          -DCMAKE_BUILD_TYPE=Release
      run_with_spinner "Building fish (this may take a few minutes)" \
        cmake --build "${build_dir}/fish-shell/build"
      run_with_spinner "Installing fish to ~/.local" \
        cmake --install "${build_dir}/fish-shell/build"

      rm -rf "${build_dir}"
      trap - EXIT

      if "${HOME}/.local/bin/fish" --version &>/dev/null; then
        print_success "fish installed: $("${HOME}/.local/bin/fish" --version)"
      else
        print_error "fish installation failed"
        exit 1
      fi
    fi
  fi

  # --- Bootstrap phase (always runs) ---
  bootstrap_fisher

  # --- Login shell setup ---
  local fish_bin="${HOME}/.local/bin/fish"
  if ! grep -qxF "${fish_bin}" /etc/shells 2>/dev/null; then
    print_info "Adding ${fish_bin} to /etc/shells (requires sudo)..."
    if ${DRY_RUN}; then
      print_dry "Would add ${fish_bin} to /etc/shells"
    else
      echo "${fish_bin}" | sudo tee -a /etc/shells >/dev/null
      print_success "Added ${fish_bin} to /etc/shells"
    fi
  else
    print_success "${fish_bin} already in /etc/shells"
  fi

  if [[ "${SHELL}" != "${fish_bin}" ]]; then
    print_info "Changing login shell to ${fish_bin}..."
    if ${DRY_RUN}; then
      print_dry "Would run: chsh -s ${fish_bin}"
    else
      chsh -s "${fish_bin}"
      print_success "Login shell changed to ${fish_bin}"
    fi
  else
    print_success "Login shell is already ${fish_bin}"
  fi
  echo
}
