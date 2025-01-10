#!/bin/bash

# Navigate to the .config folder in your repo
cd .config || { echo "Error: .config directory not found!"; exit 1; }

# Iterate over files and directories inside .config
find . -type f | while read -r config_file; do
    # Build the target path inside the user's ~/.config directory
    target="$HOME/.config/$config_file"

    # Get the parent directory of the config file
    target_dir=$(dirname "$target")

    # Create the parent directory structure if it doesn't exist
    if [ ! -d "$target_dir" ]; then
        echo "Creating directory: $target_dir"
        mkdir -p "$target_dir"
    fi

    # Check if the symlink already exists and remove it if so
    if [ -L "$target" ]; then
        echo "Removing existing symlink: $target"
        rm "$target"
    fi

    # Create the symlink to the config file
    echo "Creating symlink: $target -> $(pwd)/$config_file"
    ln -s "$(pwd)/$config_file" "$target"
done
