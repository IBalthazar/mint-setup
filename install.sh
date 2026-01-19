#!/bin/bash

# Define your dotfiles directory
DOTFILES_DIR=~/mint-setup

echo "🚀 Starting Linux Mint Setup..."

# --- Function to backup and link ---
link_config() {
    SOURCE="$DOTFILES_DIR/$1"
    TARGET="$HOME/.config/$1"

    echo "---------------------------------"
    echo "Processing $1..."

    # Check if the folder exists in your repo
    if [ ! -e "$SOURCE" ]; then
        echo "⚠️ Warning: $SOURCE not found in repo. Skipping."
        return
    fi

    # Backup existing config on the new machine if it exists
    if [ -e "$TARGET" ] || [ -L "$TARGET" ]; then
        echo "📦 Backing up existing $1 to $1.backup..."
        mv "$TARGET" "${TARGET}.backup"
    fi

    # Create the symlink
    ln -s "$SOURCE" "$TARGET"
    echo "✅ Linked $1 successfully!"
}

# --- 1. Link Configuration Folders ---
# List all the folders you copied to your repo here
link_config "i3"
link_config "kitty"
link_config "neofetch"
link_config "gtk-3.0"
link_config "picom"

# --- 2. Handle i3status (Special Case) ---
# i3status usually lives in /etc/, but for user config we put it in ~/.config/i3status/
mkdir -p ~/.config/i3status
if [ -f "$DOTFILES_DIR/i3status.conf" ]; then
    # Backup if exists
    [ -f ~/.config/i3status/config ] && mv ~/.config/i3status/config ~/.config/i3status/config.backup
    
    # Link it
    ln -s "$DOTFILES_DIR/i3status.conf" ~/.config/i3status/config
    echo "✅ Linked i3status config!"
fi

# --- 3. Handle Wallpapers ---
if [ -d "$DOTFILES_DIR/wallpapers" ]; then
    echo "🖼️ Copying wallpapers to ~/Pictures/..."
    mkdir -p ~/Pictures/wallpapers
    cp -r "$DOTFILES_DIR/wallpapers/"* ~/Pictures/wallpapers/
    echo "✅ Wallpapers copied!"
else
    echo "⚠️ No wallpapers folder found."
fi

# --- 4. Link Bashrc (Home Folder) ---
if [ -f "$DOTFILES_DIR/.bashrc" ]; then
    echo "---------------------------------"
    echo "Processing .bashrc..."
    
    # Backup existing .bashrc
    [ -f ~/.bashrc ] && mv ~/.bashrc ~/.bashrc.backup
    
    # Link it to Home directory (NOT .config)
    ln -s "$DOTFILES_DIR/.bashrc" ~/.bashrc
    echo "✅ Linked .bashrc successfully!"
fi

# --- 5. Install Packages ---
if [ -f "$DOTFILES_DIR/packages.txt" ]; then
    echo "---------------------------------"
    read -p "📦 Do you want to install apps from packages.txt? (y/n) " answer
    if [[ $answer =~ ^[Yy]$ ]]; then
        echo "⬇️ Installing packages..."
        xargs -a "$DOTFILES_DIR/packages.txt" sudo apt install -y
    else
        echo "⏭️ Skipping package installation."
    fi
else
    echo "⚠️ packages.txt not found. Skipping apps."
fi

echo "---------------------------------"
echo "🎉 Setup Complete! Please restart i3 (Mod+Shift+R) or reboot."

