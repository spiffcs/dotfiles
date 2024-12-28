# starts the shell with vi bindings
fish_vi_key_bindings

# add additional path for installed software
set PATH /usr/local/bin /usr/sbin /opt/homebrew/bin ~/.cargo/bin $PATH
if status is-interactive
    # Commands to run in interactive sessions can go here
end

# mise setup for different languages
~/.local/bin/mise activate fish | source

# BEGIN opam configuration
# This is useful if you're using opam as it adds:
#   - the correct directories to the PATH
#   - auto-completion for the opam binary
# This section can be safely removed at any time if needed.
test -r '/Users/hal/.opam/opam-init/init.fish' && source '/Users/hal/.opam/opam-init/init.fish' > /dev/null 2> /dev/null; or true
# END opam configuration
