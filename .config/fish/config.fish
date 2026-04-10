# starts the shell with vi bindings
fish_vi_key_bindings


alias xdg-open="open"
alias hfc="huggingface-cli"

# add additional path for installed software
set PATH /usr/local/bin /usr/sbin $PATH
set PATH /opt/homebrew/bin $PATH
set PATH ~/go/bin $PATH
set PATH ~/.local/bin $PATH
set PATH ~/.opam/default/bin $PATH
set PATH $HOME/.cargo/bin $PATH

# Generate cached shell integrations if missing (bootstrap handles this, fallback for manual installs)
if command -q uv; and not test -f ~/.config/fish/completions/uv.fish
    uv generate-shell-completion fish > ~/.config/fish/completions/uv.fish
end
if command -q fzf; and not test -f ~/.config/fish/conf.d/fzf.fish
    fzf --fish > ~/.config/fish/conf.d/fzf.fish
end

set -x FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'

if status is-interactive
    # Commands to run in interactive sessions can go here
end
