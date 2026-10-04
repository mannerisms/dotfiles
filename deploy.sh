#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
OS="$(uname)"

ask() {
    echo ""
    read -p "$1 (y/n) " -n 1 -r
    echo ""
    [[ $REPLY =~ ^[Yy]$ ]]
}

backup_dotfiles() {
    for file in ~/.bashrc ~/.zshrc; do
        if [ -f "$file" ] && [ ! -L "$file" ]; then
            echo "Backing up $file -> $file.bak"
            mv -f "$file" "$file.bak"
        fi
    done
}

install_deps() {
    if [ "$OS" == "Darwin" ]; then
        brew update
        brew bundle --file="$DOTFILES_DIR/Brewfile"
        # Full keyboard access: let Tab/arrows move focus between all controls
        defaults write -g AppleKeyboardUIMode -int 2
    elif [ "$OS" == "Linux" ]; then
        sudo bash "$DOTFILES_DIR/scripts/install/install-deps-linux.sh"
        echo "Note: install Hack Nerd Font manually on Linux (https://www.nerdfonts.com/font-downloads)"

        if ! command -v starship >/dev/null 2>&1; then
            echo "Installing starship"
            sudo sh -c "$(curl -fsSL https://starship.rs/install.sh)"
        fi
    fi
}

ensure_stow() {
    if ! command -v stow >/dev/null 2>&1; then
        echo "Installing stow"
        if [ "$OS" == "Darwin" ]; then
            brew install stow
        elif [ "$OS" == "Linux" ]; then
            sudo apt-get install -y stow
        fi
    fi
}

build_borders() {
    # JankyBorders focus border for AeroSpace: built from source into the (git-ignored) config folder
    local dir="$DOTFILES_DIR/.config/aerospace/borders"
    if [ "$OS" == "Darwin" ] && [ ! -x "$dir/bin/borders" ]; then
        git clone --depth 1 https://github.com/FelixKratz/JankyBorders.git "$dir"
        make -C "$dir"
    fi
}

# ── Main ────────────────────────────────────────────────────────────────────

echo "Detected OS: $OS"

if ask "Install dependencies?"; then
    install_deps
fi

ensure_stow
backup_dotfiles

echo "Stowing dotfiles from $DOTFILES_DIR"
cd "$DOTFILES_DIR"
stow .

if ask "Build the AeroSpace focus border (JankyBorders)?"; then
    build_borders
fi

echo ""
echo "Done."
