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
set PATH $HOME/miniconda3/bin $PATH

# Load pyenv automatically if installed
if command -q pyenv
    status is-interactive; and source (pyenv init -| psub)
end

# Load uv shell completions if installed
if command -q uv
    uv generate-shell-completion fish | source
end

# Set up fzf key bindings
fzf --fish | source

if status is-interactive
    # Commands to run in interactive sessions can go here
end

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if test -f /Users/hal/miniconda3/bin/conda
    eval /Users/hal/miniconda3/bin/conda "shell.fish" "hook" $argv | source
else
    if test -f "/Users/hal/miniconda3/etc/fish/conf.d/conda.fish"
        . "/Users/hal/miniconda3/etc/fish/conf.d/conda.fish"
    else
        set -x PATH "/Users/hal/miniconda3/bin" $PATH
    end
end
# <<< conda initialize <<<

