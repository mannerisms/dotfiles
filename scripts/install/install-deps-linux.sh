#!/bin/bash
set -e

apt-get update

read -p "Upgrade existing apt packages? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    apt-get upgrade -y
fi

# CLI tools
apt-get install -y bat
apt-get install -y fzf
apt-get install -y stow
apt-get install -y tmux
apt-get install -y trash-cli
apt-get install -y tree
apt-get install -y yt-dlp

# Zoxide (not in apt)
if ! command -v zoxide >/dev/null 2>&1; then
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi

# NVM (not in apt)
if ! command -v nvm >/dev/null 2>&1; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
fi

# ZSH plugins (not in apt)
read -p "Install zsh and plugins? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    apt-get install -y zsh
    apt-get install -y zsh-autosuggestions
    apt-get install -y zsh-syntax-highlighting

    # zsh-history-substring-search (not in apt)
    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.zsh}"
    mkdir -p "$ZSH_CUSTOM"
    if [ ! -d "$ZSH_CUSTOM/zsh-history-substring-search" ]; then
        git clone https://github.com/zsh-users/zsh-history-substring-search "$ZSH_CUSTOM/zsh-history-substring-search"
    fi

    # zsh-you-should-use (not in apt)
    if [ ! -d "$ZSH_CUSTOM/zsh-you-should-use" ]; then
        git clone https://github.com/MichaelAquilina/zsh-you-should-use "$ZSH_CUSTOM/zsh-you-should-use"
    fi

    chsh -s "$(which zsh)"
fi
