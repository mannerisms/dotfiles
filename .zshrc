# === Path Configuration ===
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
export PATH="/opt/homebrew/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# === Editor Configuration ===
export EDITOR=vim
export VISUAL=$EDITOR

# === History Configuration ===
export HISTFILE=~/.zsh_history
export HISTSIZE=50000
export SAVEHIST=100000
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt EXTENDED_HISTORY
setopt HIST_VERIFY

# === Source Configuration Files ===
typeset -a config_files=(
    ~/.sh/aliases.sh
    ~/.sh/functions.sh
    ~/.zsh/functions.zsh
    ~/.zsh/plugins.zsh
    ~/.zsh/bindkeys.zsh
)

for file in $config_files; do
    [[ -f $file ]] && source $file
done

# === System Specific Configuration ===
if [[ -f /usr/bin/setxkbmap ]]; then
    setxkbmap -option caps:escape || echo "Failed to remap caps lock to escape"
fi

# === Zoxide (smart directory jumping) ===
eval "$(zoxide init zsh)"

# === Starship Prompt ===
export STARSHIP_CONFIG=~/.config/starship/starship.toml
eval "$(starship init zsh)"

# === Docker CLI completions ===
fpath=(/Users/bastiaan/.docker/completions $fpath)
autoload -Uz compinit && compinit

# === NVM (lazy-loaded) ===
export NVM_DIR="$HOME/.nvm"
nvm() {
    unset -f nvm node npm npx
    [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && source "/opt/homebrew/opt/nvm/nvm.sh"
    nvm "$@"
}
node() { unset -f nvm node npm npx; [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && source "/opt/homebrew/opt/nvm/nvm.sh"; node "$@"; }
npm()  { unset -f nvm node npm npx; [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && source "/opt/homebrew/opt/nvm/nvm.sh"; npm "$@"; }
npx()  { unset -f nvm node npm npx; [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && source "/opt/homebrew/opt/nvm/nvm.sh"; npx "$@"; }
