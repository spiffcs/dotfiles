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

# Load uv shell completions if installed
if command -q uv
    uv generate-shell-completion fish | source
end

# Set up fzf key bindings
fzf --fish | source
set -x FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'

if status is-interactive
    # Commands to run in interactive sessions can go here
end
