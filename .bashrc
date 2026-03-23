nano ~/.bashrc

###############################################################

# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# =========================
# HISTORY BASE + ROBUSTA
# =========================

# Dimensione history
HISTSIZE=100000
HISTFILESIZE=200000

# Mostra data e ora con history
export HISTTIMEFORMAT="%F %T "

# Evita duplicati e comandi con spazio iniziale
export HISTCONTROL=ignoreboth:erasedups

# Append invece di overwrite
shopt -s histappend

# Salvataggio immediato e sync tra terminali
PROMPT_COMMAND='history -a; history -n'

# Non escludere nulla dalla history
unset HISTIGNORE

# =========================
# VARIE
# =========================

# Aggiorna dimensioni terminale
shopt -s checkwinsize

# Supporto less
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Chroot (se presente)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# =========================
# PROMPT (con orario)
# =========================

PS1='[\t] ${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# Titolo finestra
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# =========================
# COLORI E ALIAS
# =========================

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"

    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Alias utili
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Notifica fine comando lungo
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history | tail -n1 | sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# =========================
# ALIAS CUSTOM
# =========================

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# =========================
# BASH COMPLETION
# =========================

if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
