#!/bin/bash
#
# Bootstrap script for dotfiles on a fresh machine.
# Installs dependencies, builds fish from source, creates symlinks,
# and sets up the development environment.

set -uo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Script directory (where dotfiles repo lives)
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly DOTFILES_DIR

# Flags
DRY_RUN=false
DO_SYMLINK=false
DO_DEPS=false
DO_RUST=false
DO_LSP=false
DO_FISH=false
DO_CLEAN_BACKUPS=false

# -----------------------------------------------------------------------------
# Helper functions
# -----------------------------------------------------------------------------

print_info() {
  echo -e "${BLUE}[INFO]${NC} ${1}"
}

print_success() {
  echo -e "${GREEN}[OK]${NC} ${1}"
}

print_warning() {
  echo -e "${YELLOW}[WARN]${NC} ${1}" >&2
}

print_error() {
  echo -e "${RED}[ERROR]${NC} ${1}" >&2
}

print_dry() {
  echo -e "${YELLOW}[DRY-RUN]${NC} ${1}"
}

# -----------------------------------------------------------------------------
# Spinner for long-running commands
# -----------------------------------------------------------------------------

_spinner_pid=""

# Starts a background spinner with a message.
# Globals:
#   _spinner_pid
# Arguments:
#   msg - text to display next to the spinner
_start_spinner() {
  local msg="${1}"
  if [[ ! -t 1 ]]; then
    printf "  ... %s\n" "${msg}"
    return
  fi
  (
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0
    while true; do
      printf "\r  ${BLUE}%s${NC} %s" "${spin:i++%${#spin}:1}" "${msg}"
      sleep 0.1
    done
  ) &
  _spinner_pid=$!
}

# Stops the spinner and prints a success/failure indicator.
# Globals:
#   _spinner_pid
# Arguments:
#   exit_code - 0 for success, non-zero for failure
#   msg - text to display next to the indicator
_stop_spinner() {
  local exit_code="${1}"
  local msg="${2}"
  if [[ -n "${_spinner_pid}" ]]; then
    kill "${_spinner_pid}" 2>/dev/null
    wait "${_spinner_pid}" 2>/dev/null || true
    _spinner_pid=""
  fi
  if [[ -t 1 ]]; then
    if (( exit_code == 0 )); then
      printf "\r  ${GREEN}✔${NC} %s\n" "${msg}"
    else
      printf "\r  ${RED}✘${NC} %s\n" "${msg}"
    fi
  fi
}

# Runs a command with a spinner, showing progress to the user.
# Arguments:
#   msg - description shown during execution
#   ... - command and arguments to run
# Returns:
#   Exit code of the executed command.
run_with_spinner() {
  local msg="${1}"
  shift
  if ${DRY_RUN}; then
    print_dry "Would run: $*"
    return 0
  fi
  _start_spinner "${msg}"
  local output
  local exit_code=0
  output=$("$@" 2>&1) || exit_code=$?
  _stop_spinner "${exit_code}" "${msg}"
  if (( exit_code != 0 )); then
    echo "${output}" | tail -5 >&2
  fi
  return "${exit_code}"
}

# -----------------------------------------------------------------------------
# Symlink functions
# -----------------------------------------------------------------------------

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

  # Create parent directory if needed
  if [[ ! -d "${target_dir}" ]]; then
    if ${DRY_RUN}; then
      print_dry "Would create directory: ${target_dir}"
    else
      mkdir -p "${target_dir}"
      print_info "Created directory: ${target_dir}"
    fi
  fi

  # Handle existing files/symlinks
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

  # Create the symlink
  if ${DRY_RUN}; then
    print_dry "Would link: ${target} -> ${src}"
  else
    ln -s "${src}" "${target}"
    print_success "Linked: ${target} -> ${src}"
  fi
}

# Ensures Fisher is installed and all plugins from fish_plugins are present.
# Skips silently if fish is not installed.
# Globals:
#   HOME, DRY_RUN, DOTFILES_DIR
bootstrap_fisher() {
  local fish_bin="${HOME}/.local/bin/fish"
  if ! command -v "${fish_bin}" &>/dev/null; then
    return 0
  fi

  # Ensure fish_plugins symlink exists (needed before fisher update)
  local fish_plugins_target="${HOME}/.config/fish/fish_plugins"
  local fish_plugins_source="${DOTFILES_DIR}/.config/fish/fish_plugins"
  if [[ ! -e "${fish_plugins_target}" && -f "${fish_plugins_source}" ]]; then
    mkdir -p "$(dirname "${fish_plugins_target}")"
    if ${DRY_RUN}; then
      print_dry "Would link: ${fish_plugins_target} -> ${fish_plugins_source}"
    else
      ln -s "${fish_plugins_source}" "${fish_plugins_target}"
      print_success "Linked: ${fish_plugins_target} -> ${fish_plugins_source}"
    fi
  fi

  # Install Fisher if not present, then ensure all plugins are installed.
  # shellcheck disable=SC2016 # $plugin/$installed are fish variables, not bash
  if ${DRY_RUN}; then
    print_dry "Would install Fisher and plugins from fish_plugins"
  elif ! "${fish_bin}" -c 'type -q fisher' 2>/dev/null; then
    run_with_spinner "Installing Fisher and plugins" \
      "${fish_bin}" -c '
        curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
        fisher install jorgebucaran/fisher
        fisher update
      '
  elif "${fish_bin}" -c '
      set -l installed (fisher list)
      for plugin in (cat ~/.config/fish/fish_plugins)
        contains -- $plugin $installed; or exit 1
      end
    ' 2>/dev/null; then
    print_success "Fisher plugins already installed"
  else
    run_with_spinner "Installing missing Fisher plugins" \
      "${fish_bin}" -c '
        set -l installed (fisher list)
        for plugin in (cat ~/.config/fish/fish_plugins)
          if not contains -- $plugin $installed
            fisher install $plugin
          end
        end
      '
  fi
}

# Symlinks an entire .config subdirectory.
# Arguments:
#   config_name - name of the directory under .config/
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
# Arguments:
#   filename - name of the file (e.g. ".gitconfig")
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

  # Ensure ~/.config exists
  if [[ ! -d "${HOME}/.config" ]]; then
    if ${DRY_RUN}; then
      print_dry "Would create directory: ${HOME}/.config"
    else
      mkdir -p "${HOME}/.config"
    fi
  fi

  # Symlink .config directories
  print_info "Symlinking .config directories..."
  symlink_fish_config
  symlink_config_dir "ghostty"
  symlink_config_dir "git"
  symlink_config_dir "nvim"
  echo

  # Symlink root dotfiles
  print_info "Symlinking root dotfiles..."
  symlink_root_file ".gitconfig"
  symlink_root_file ".gitattributes"
  symlink_root_file ".commit-template.txt"
  echo

  # Install nvim plugins
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

  # Remind about .gitconfig.local
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

# -----------------------------------------------------------------------------
# Dependency installation
# -----------------------------------------------------------------------------

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

# -----------------------------------------------------------------------------
# Install Rust toolchain
# -----------------------------------------------------------------------------

do_rust() {
  print_info "Setting up Rust toolchain..."
  echo

  if ! command -v rustup &>/dev/null; then
    print_error "rustup is not installed. Run --deps first to install it via Homebrew."
    exit 1
  fi

  # Check if a default toolchain is already installed
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

  # Install tree-sitter CLI (needed by nvim-treesitter to compile parsers)
  run_with_spinner "Installing tree-sitter-cli" cargo install tree-sitter-cli
  echo
}

# -----------------------------------------------------------------------------
# Install LSP servers
# -----------------------------------------------------------------------------

do_lsp() {
  print_info "Installing LSP servers..."
  echo

  # gopls (requires Go)
  if command -v go &>/dev/null; then
    run_with_spinner "Installing gopls" \
      go install golang.org/x/tools/gopls@latest
  else
    print_warning "go not found — skipping gopls (run --deps first)"
  fi

  # pyright + ruff (requires uv)
  if command -v uv &>/dev/null; then
    run_with_spinner "Installing pyright" uv tool install pyright
    run_with_spinner "Installing ruff" uv tool install ruff
  else
    print_warning "uv not found — skipping pyright and ruff (run --deps first)"
  fi

  # rust-analyzer (requires rustup)
  if command -v rustup &>/dev/null; then
    run_with_spinner "Installing rust-analyzer" \
      rustup component add rust-analyzer
  else
    print_warning "rustup not found — skipping rust-analyzer (run --rust first)"
  fi

  # metals + JDK (requires coursier)
  if command -v cs &>/dev/null; then
    run_with_spinner "Pre-caching JDK 21 via coursier" \
      cs java-home --jvm 21
    run_with_spinner "Installing metals" cs install metals
  else
    print_warning "cs (coursier) not found — skipping metals (run --deps first)"
  fi

  echo
}

# -----------------------------------------------------------------------------
# Build fish from source
# -----------------------------------------------------------------------------

# Builds fish from source (if needed) and bootstraps Fisher, plugins,
# and login shell configuration.
do_fish() {
  print_info "Building fish shell from source..."
  echo

  # Check prerequisites
  local missing=()
  local cmd
  for cmd in cmake cargo cc; do
    if ! command -v "${cmd}" &>/dev/null; then
      missing+=("${cmd}")
    fi
  done
  if (( ${#missing[@]} > 0 )); then
    print_error "Missing required tools: ${missing[*]}"
    print_info "Install cmake via Homebrew (brew install cmake) or your package manager"
    print_info "Install cargo via rustup (https://rustup.rs)"
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
      print_success "fish ${latest_tag} is already installed at ~/.local/bin/fish"
      needs_build=false
    fi
  fi

  if ${needs_build}; then
    if ${DRY_RUN}; then
      print_dry "Would clone fish-shell/fish-shell at tag ${latest_tag}"
      print_dry "Would build with cmake (install prefix: \${HOME}/.local)"
      print_dry "Would install to ~/.local/bin/fish"
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

      # Verify
      if "${HOME}/.local/bin/fish" --version &>/dev/null; then
        print_success "fish installed: $("${HOME}/.local/bin/fish" --version)"
      else
        print_error "fish installation failed — ~/.local/bin/fish not working"
        exit 1
      fi
    fi
  fi

  # --- Bootstrap phase (always runs) ---
  bootstrap_fisher

  # Set fish as login shell
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

# -----------------------------------------------------------------------------
# Interactive mode
# -----------------------------------------------------------------------------

interactive_mode() {
  echo
  echo "Dotfiles Installation"
  echo "====================="
  echo
  echo "This script will set up your dotfiles."
  echo "Repository: ${DOTFILES_DIR}"
  echo
  echo "Options:"
  echo "  1) Install everything (dependencies + rust + LSP servers + fish + symlinks)"
  echo "  2) Install dependencies only (Homebrew packages)"
  echo "  3) Install Rust toolchain"
  echo "  4) Install LSP servers (gopls, pyright, ruff, rust-analyzer, metals)"
  echo "  5) Build fish from source"
  echo "  6) Create symlinks only"
  echo "  7) Clean up backup files"
  echo "  8) Dry run (show what would happen)"
  echo "  9) Exit"
  echo
  read -rp "Choose an option [1-9]: " choice

  case "${choice}" in
    1) DO_DEPS=true; DO_RUST=true; DO_LSP=true; DO_FISH=true; DO_SYMLINK=true ;;
    2) DO_DEPS=true ;;
    3) DO_RUST=true ;;
    4) DO_LSP=true ;;
    5) DO_FISH=true ;;
    6) DO_SYMLINK=true ;;
    7) DO_CLEAN_BACKUPS=true ;;
    8) DRY_RUN=true; DO_DEPS=true; DO_RUST=true; DO_LSP=true; DO_FISH=true; DO_SYMLINK=true ;;
    9) exit 0 ;;
    *) print_error "Invalid option"; exit 1 ;;
  esac
}

# -----------------------------------------------------------------------------
# Usage
# -----------------------------------------------------------------------------

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Bootstrap dotfiles on a fresh machine.

Options:
    --all             Install everything (deps + rust + LSP + fish + symlinks)
    --deps            Install Homebrew dependencies only
    --rust            Install Rust stable toolchain via rustup
    --lsp             Install LSP servers
    --fish            Build and install fish from source
    --symlink         Create symlinks only
    --clean-backups   Remove *.backup.* files left by previous runs
    --dry-run         Show what would be done without making changes
    -h, --help        Show this help message

Examples:
    $(basename "$0")              # Interactive mode
    $(basename "$0") --all        # Full installation
    $(basename "$0") --rust       # Install Rust toolchain only
    $(basename "$0") --lsp        # Install LSP servers only
    $(basename "$0") --fish       # Build fish from source only
    $(basename "$0") --symlink    # Symlinks only (if deps already installed)
    $(basename "$0") --dry-run    # Preview all changes

EOF
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------

main() {
  while (( $# > 0 )); do
    case "${1}" in
      --all)
        DO_DEPS=true
        DO_RUST=true
        DO_LSP=true
        DO_FISH=true
        DO_SYMLINK=true
        shift
        ;;
      --deps)          DO_DEPS=true; shift ;;
      --rust)          DO_RUST=true; shift ;;
      --lsp)           DO_LSP=true; shift ;;
      --fish)          DO_FISH=true; shift ;;
      --symlink)       DO_SYMLINK=true; shift ;;
      --clean-backups) DO_CLEAN_BACKUPS=true; shift ;;
      --dry-run)       DRY_RUN=true; shift ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        print_error "Unknown option: ${1}"
        usage
        exit 1
        ;;
    esac
  done

  echo
  print_info "Dotfiles directory: ${DOTFILES_DIR}"
  if ${DRY_RUN}; then
    print_warning "Dry run mode - no changes will be made"
  fi
  echo

  # If no action flags specified, run interactive mode (sets flags)
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
