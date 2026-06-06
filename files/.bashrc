# ── Termux bashrc ──────────────────────────────
# Part of github.com/YOU/termux-setup
# This file gets copied to ~/.bashrc by update.sh

export TERM=xterm-256color
export EDITOR=nano

# Navigation
alias q='exit'
alias c='clear'
alias ..='cd ..'
alias ...='cd ../..'

# File listing
alias ls='ls --color=auto'
alias ll='ls -la'
alias la='ls -A'

# Termux shortcuts
alias update='pkg update && pkg upgrade -y'
alias myip='curl -s ifconfig.me && echo'

# Git shortcuts
alias gs='git status'
alias gp='git pull'
alias gc='git clone'

# Custom prompt: user@termux:~/path$
PS1='\[\e[36m\]\u\[\e[0m\]@\[\e[32m\]termux\[\e[0m\]:\[\e[33m\]\w\[\e[0m\]\$ '
