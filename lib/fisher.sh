# shellcheck shell=bash
# Fisher plugin manager bootstrap.
# Sourced by install.sh — do not execute directly.

# Ensures Fisher is installed and all plugins from fish_plugins are present.
# Skips silently if fish or fish_plugins are not available.
# Globals:
#   HOME, DRY_RUN, DOTFILES_DIR
bootstrap_fisher() {
  local fish_bin="${HOME}/.local/bin/fish"
  local fish_plugins="${HOME}/.config/fish/fish_plugins"

  if ! command -v "${fish_bin}" &>/dev/null; then
    return 0
  fi

  # Ensure fish_plugins symlink exists (needed before fisher runs)
  if [[ ! -e "${fish_plugins}" && -f "${DOTFILES_DIR}/.config/fish/fish_plugins" ]]; then
    mkdir -p "$(dirname "${fish_plugins}")"
    if ${DRY_RUN}; then
      print_dry "Would link: ${fish_plugins}"
    else
      ln -s "${DOTFILES_DIR}/.config/fish/fish_plugins" "${fish_plugins}"
      print_success "Linked: ${fish_plugins}"
    fi
  fi

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
