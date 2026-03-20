#!/bin/bash
set -e

brew update

read -p "Upgrade existing brew packages? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    brew upgrade
fi

# CLI tools
brew install bat
brew install fzf
brew install stow
brew install tmux
brew install tree
brew install yt-dlp
brew install zoxide
brew install starship

# ZSH plugins
brew install zsh-autosuggestions
brew install zsh-history-substring-search
brew install zsh-syntax-highlighting
brew install zsh-you-should-use

# Casks
brew install --cask alacritty
brew install --cask istat-menus
brew install --cask logseq
brew install --cask trash
