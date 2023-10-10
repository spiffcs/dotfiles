# starts the shell with vi bindings
fish_vi_key_bindings

# add additional path for installed software
set PATH /usr/local/bin /usr/sbin $PATH
if status is-interactive
    # Commands to run in interactive sessions can go here
end
