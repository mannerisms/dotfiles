# === Path Configuration ===
# Prepend to the inherited PATH (do not replace it); typeset -U drops duplicates
typeset -U path PATH
path=(/opt/homebrew/bin /opt/homebrew/sbin "$HOME/.local/bin" $path)

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

# === Starship Prompt ===
export STARSHIP_CONFIG=~/.config/starship/starship.toml
eval "$(starship init zsh)"

# === Docker CLI completions ===
fpath=("$HOME/.docker/completions" $fpath)

# === Completion ===
fpath+=~/.zfunc
autoload -Uz compinit
# Full compinit security check only when the dump is older than 24h, otherwise use the cache (-C)
() {
    setopt local_options extendedglob
    if [[ -n $HOME/.zcompdump(#qN.mh+24) ]]; then compinit && touch "$HOME/.zcompdump"; else compinit -C; fi
}

zstyle ':completion:*' menu select

# === Zoxide (smart directory jumping), must come after compinit ===
eval "$(zoxide init zsh)"
