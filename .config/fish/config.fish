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

# Set up fzf key bindings
fzf --fish | source

if status is-interactive
    # Commands to run in interactive sessions can go here
end
