git pull
read -p "This may overwrite some files in your home directory that already exist. Are you sure you want to proceed? (y/n)" -n 1
if [[$REPLY =~ ^[Yy]$]]; then
  rsync --exclude ".git/" --exclude ".DS_Store" --exclude ".osx" --exclude "bootstrap.sh" --exclude "README.md" -av . ~
fi
echo
