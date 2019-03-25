#!/bin/bash
cd "$(dirname "$0")";
git pull
read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1
echo

for file in .{aliases,exports,extra,functions,gitattributes,gitconfig,gitignore,zshrc}; do
    [ -r "$file" ] && ln -sf $(pwd)/"$file" ~/${file}
    echo "Setting sym link for $file"
done
unset file

