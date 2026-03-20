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

install_fonts() {
    if [ "$OS" == "Darwin" ]; then
        FONT_DIR="$HOME/Library/Fonts"
    else
        FONT_DIR="$HOME/.fonts"
        mkdir -p "$FONT_DIR"
    fi

    echo "Copying fonts to $FONT_DIR/"
    cp "$DOTFILES_DIR"/fonts/* "$FONT_DIR/"

    if [ "$OS" == "Linux" ]; then
        fc-cache -fv
    fi
}

install_deps() {
    if [ "$OS" == "Darwin" ]; then
        bash "$DOTFILES_DIR/scripts/install/install-deps-macos.sh"
    elif [ "$OS" == "Linux" ]; then
        sudo bash "$DOTFILES_DIR/scripts/install/install-deps-linux.sh"

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

install_fonts

echo ""
echo "Done."
