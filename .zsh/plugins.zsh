# Source the first path that exists
_source_plugin() {
    for path in "$@"; do
        [[ -f "$path" ]] && source "$path" && return
    done
    echo "warning: plugin not found: $1"
}

_source_plugin \
    /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
    /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

_source_plugin \
    /opt/homebrew/share/zsh-you-should-use/you-should-use.plugin.zsh \
    ~/.zsh/zsh-you-should-use/you-should-use.plugin.zsh

_source_plugin \
    /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
    /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh

_source_plugin \
    /opt/homebrew/share/zsh-history-substring-search/zsh-history-substring-search.zsh \
    ~/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh

eval "$(fzf --zsh)"

ZSH_AUTOSUGGEST_STRATEGY=(history)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=240'
