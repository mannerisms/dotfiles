# ALIASES ---------------------------------------------------------------------

# Vim
alias vim="vim -p"

# Edit dotfiles
alias dotconfig="cd $HOME/dotfiles"
alias zshconfig="vim $HOME/dotfiles/.zshrc"

# Reload shell config
alias s="source ~/.zshrc"

# Git aliases
alias gst='git status'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit'
alias gcam='git commit -am'
alias gp="git push"
alias gpd="git push --dry-run"
alias gpf="git push --force"
alias gl="git pull"
alias gd='git diff'
alias gco='git checkout'

# List
alias la='ls -lGa'
alias ls='ls -lG'

# Docker aliases
alias d=docker
alias dc=docker-compose
alias dkill="pgrep 'Docker' | xargs kill -9"

# Tmux aliases
alias tmb='tmux new-session -A -s base'
alias ta='tmux attach -t'

# Misc
alias cat='bat'
alias c='clear'
alias rm=trash
alias trim="awk '{\$1=\$1;print}'"
alias chx='chmod +x'
