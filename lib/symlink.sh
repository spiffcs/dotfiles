# shellcheck shell=bash
# Symlink creation, backup, and cleanup functions.
# Sourced by install.sh — do not execute directly.

# Backs up an existing non-symlink file by appending a timestamp.
# Arguments:
#   target - path to the file to back up
backup_existing() {
  local target="${1}"
  if [[ -e "${target}" && ! -L "${target}" ]]; then
    local backup
    backup="${target}.backup.$(date +%Y%m%d%H%M%S)"
    if ${DRY_RUN}; then
      print_dry "Would backup: ${target} -> ${backup}"
    else
      mv "${target}" "${backup}"
      print_warning "Backed up existing file: ${target} -> ${backup}"
    fi
  fi
}

# Creates a symlink from src to target, handling existing files/links.
# Arguments:
#   src - source path (in dotfiles repo)
#   target - destination path
create_symlink() {
  local src="${1}"
  local target="${2}"
  local target_dir
  target_dir="$(dirname "${target}")"

  if [[ ! -d "${target_dir}" ]]; then
    if ${DRY_RUN}; then
      print_dry "Would create directory: ${target_dir}"
    else
      mkdir -p "${target_dir}"
      print_info "Created directory: ${target_dir}"
    fi
  fi

  if [[ -L "${target}" ]]; then
    local current_target
    current_target="$(readlink "${target}")"
    if [[ "${current_target}" == "${src}" ]]; then
      print_success "Already linked: ${target}"
      return 0
    else
      if ${DRY_RUN}; then
        print_dry "Would remove existing symlink: ${target} -> ${current_target}"
      else
        rm "${target}"
        print_info "Removed old symlink: ${target}"
      fi
    fi
  elif [[ -e "${target}" ]]; then
    backup_existing "${target}"
  fi

  if ${DRY_RUN}; then
    print_dry "Would link: ${target} -> ${src}"
  else
    ln -s "${src}" "${target}"
    print_success "Linked: ${target} -> ${src}"
  fi
}

# Symlinks an entire .config subdirectory.
symlink_config_dir() {
  local config_name="${1}"
  local src="${DOTFILES_DIR}/.config/${config_name}"
  local target="${HOME}/.config/${config_name}"

  if [[ -d "${src}" ]]; then
    create_symlink "${src}" "${target}"
  else
    print_error "Source directory not found: ${src}"
    return 1
  fi
}

# Symlinks a dotfile from the repo root to $HOME.
symlink_root_file() {
  local filename="${1}"
  local src="${DOTFILES_DIR}/${filename}"
  local target="${HOME}/${filename}"

  if [[ -f "${src}" ]]; then
    create_symlink "${src}" "${target}"
  else
    print_error "Source file not found: ${src}"
    return 1
  fi
}

# Symlinks individual fish config files (config.fish, conf.d/*, functions/*).
# Removes auto-generated frozen files that conflict with managed config.
symlink_fish_config() {
  local fish_dir="${HOME}/.config/fish"

  # Ensure fish config directories exist as real directories
  local dir
  for dir in "${fish_dir}" "${fish_dir}/conf.d" "${fish_dir}/functions"; do
    if [[ -L "${dir}" ]]; then
      if ${DRY_RUN}; then
        print_dry "Would remove directory symlink: ${dir}"
        print_dry "Would create real directory: ${dir}"
      else
        rm "${dir}"
        print_info "Removed directory symlink: ${dir}"
      fi
    fi
    if [[ ! -d "${dir}" ]]; then
      if ${DRY_RUN}; then
        print_dry "Would create directory: ${dir}"
      else
        mkdir -p "${dir}"
        print_info "Created directory: ${dir}"
      fi
    fi
  done

  # Remove auto-generated frozen files that conflict with managed config
  local frozen_file
  for frozen_file in "${fish_dir}/conf.d/fish_frozen_theme.fish" \
                     "${fish_dir}/conf.d/fish_frozen_key_bindings.fish"; do
    if [[ -f "${frozen_file}" ]]; then
      if ${DRY_RUN}; then
        print_dry "Would remove frozen config: ${frozen_file}"
      else
        rm "${frozen_file}"
        print_info "Removed frozen config: ${frozen_file}"
      fi
    fi
  done

  # Symlink fish_plugins first, then bootstrap Fisher/Tide before conf.d
  create_symlink "${DOTFILES_DIR}/.config/fish/fish_plugins" "${fish_dir}/fish_plugins"
  bootstrap_fisher

  # Symlink remaining fish config files
  create_symlink "${DOTFILES_DIR}/.config/fish/config.fish" "${fish_dir}/config.fish"
  create_symlink "${DOTFILES_DIR}/.config/fish/conf.d/rustup.fish" "${fish_dir}/conf.d/rustup.fish"
  create_symlink "${DOTFILES_DIR}/.config/fish/conf.d/gruvbox-theme.fish" "${fish_dir}/conf.d/gruvbox-theme.fish"
  create_symlink "${DOTFILES_DIR}/.config/fish/conf.d/tide-config.fish" "${fish_dir}/conf.d/tide-config.fish"
  create_symlink "${DOTFILES_DIR}/.config/fish/functions/cat.fish" "${fish_dir}/functions/cat.fish"
  create_symlink "${DOTFILES_DIR}/.config/fish/functions/fish_greeting.fish" "${fish_dir}/functions/fish_greeting.fish"
}

do_symlink() {
  print_info "Creating symlinks..."
  echo

  if [[ ! -d "${HOME}/.config" ]]; then
    if ${DRY_RUN}; then
      print_dry "Would create directory: ${HOME}/.config"
    else
      mkdir -p "${HOME}/.config"
    fi
  fi

  print_info "Symlinking .config directories..."
  symlink_fish_config
  symlink_config_dir "ghostty"
  symlink_config_dir "git"
  symlink_config_dir "nvim"
  echo

  print_info "Symlinking root dotfiles..."
  symlink_root_file ".gitconfig"
  symlink_root_file ".gitattributes"
  symlink_root_file ".commit-template.txt"
  echo

  print_info "Installing nvim plugins..."
  if command -v nvim &>/dev/null; then
    if ${DRY_RUN}; then
      print_dry "Would run: nvim --headless '+Lazy install' +qa"
    else
      run_with_spinner "Installing nvim plugins" nvim --headless "+Lazy install" +qa
    fi
  else
    print_warning "nvim not found — skipping plugin install (run --deps first)"
  fi
  echo

  if [[ ! -f "${HOME}/.gitconfig.local" ]]; then
    print_warning "${HOME}/.gitconfig.local not found — commit signing will not work"
    print_info "Create it from the template:"
    echo "  cp ${DOTFILES_DIR}/.gitconfig.local.example ~/.gitconfig.local"
    echo
  fi

  print_success "Symlink setup complete!"
}

# Removes *.backup.* files created by backup_existing().
# Searches $HOME and $HOME/.config for backup files.
do_clean_backups() {
  print_info "Searching for backup files..."
  echo

  local backups=()
  local file
  while IFS= read -r -d '' file; do
    backups+=("${file}")
  done < <(find "${HOME}" "${HOME}/.config" \
    -maxdepth 4 -name "*.backup.*" -print0 2>/dev/null)

  if (( ${#backups[@]} == 0 )); then
    print_success "No backup files found."
    return 0
  fi

  print_info "Found ${#backups[@]} backup file(s):"
  for file in "${backups[@]}"; do
    echo "  ${file}"
  done
  echo

  if ${DRY_RUN}; then
    print_dry "Would remove ${#backups[@]} backup file(s)"
    return 0
  fi

  for file in "${backups[@]}"; do
    rm -rf "${file}"
  done
  print_success "Removed ${#backups[@]} backup file(s)."
}
