[[ $- != *i* ]] && return

bind 'set bell-style none' 2>/dev/null
if [[ -n ${DISPLAY:-} ]] && command -v xset >/dev/null 2>&1; then
	xset b off 2>/dev/null
fi

alias ls='ls --color=auto -A'
alias grep='grep --color=auto'

PS1="\[\e[1;35m\]\u\[\e[0m\]@\[\e[1;36m\]\h\[\e[0m\] \[\e[1;34m\]\W\[\e[0m\]\$ "

alias vim='nvim'
alias top='btop'
alias off='poweroff'
alias larp='fastfetch'
alias ff='firefox &'
alias xx='g++'
alias ++='g++'

export PATH="$HOME/.platformio/penv/bin:$PATH"
