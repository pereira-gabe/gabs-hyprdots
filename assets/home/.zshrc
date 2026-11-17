# Interactive zsh configuration.

# History
HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt appendhistory
setopt sharehistory
setopt incappendhistory
setopt extendedhistory
setopt histexpiredupsfirst
setopt histfindnodups
setopt histignorealldups
setopt histignorespace
setopt histreduceblanks
setopt histsavenodups
setopt histverify

# Shell behavior
setopt autocd
setopt autopushd
setopt pushdignoredups
setopt extendedglob
setopt interactivecomments
setopt no_beep
setopt promptsubst
setopt completeinword
setopt alwaystoend
setopt automenu
setopt autolist
setopt noflowcontrol
setopt notify
setopt longlistjobs

# Key bindings
bindkey -e
# Backspace: QTerminal may send ^H instead of ^?, so map both to one char.
bindkey '^?' backward-delete-char
bindkey '^H' backward-delete-char
bindkey '^W' backward-kill-word
bindkey '^[[3;5~' kill-word
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# Completion
fpath=(/usr/share/zsh/site-functions $fpath)
autoload -Uz compinit
ZCOMPDUMP="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
mkdir -p "${ZCOMPDUMP:h}"
compinit -d "$ZCOMPDUMP"

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}%d%f'
zstyle ':completion:*:warnings' format 'No matches for: %F{red}%d%f'
zstyle ':completion:*' rehash true
zstyle ':completion:*' squeeze-slashes true

# Aliases
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias vim='nvim'
alias top='btop'
alias off='poweroff'
alias larp='fastfetch'
alias ff='firefox &'
alias xx='g++'

# Kali-style two-line prompt, using the terminal's blue.
PROMPT=$'%f┌──(%B%F{blue}%n%F{white}@%F{blue}%m%b%f)-[%B%F{white}%(6~.%-1~/…/%4~.%5~)%b%f]\n%f└─%B%F{blue}%(#.#.$)%b%f '
PROMPT2='%F{blue}%_> %f'
PROMPT_EOL_MARK=''

# Keep the QTerminal tab/window title in the same user@host: path format.
set_terminal_title() { print -Pn "\e]0;%n@%m: %~\a" }
autoload -Uz add-zsh-hook
add-zsh-hook precmd set_terminal_title
add-zsh-hook preexec set_terminal_title

# Autosuggestions
if [[ -r /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
	ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=244'
	ZSH_AUTOSUGGEST_STRATEGY=(history completion)
	source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# Fish-like history search with Up/Down
if [[ -r /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh ]]; then
	source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
	bindkey '^[[A' history-substring-search-up
	bindkey '^[[B' history-substring-search-down
	bindkey '^P' history-substring-search-up
	bindkey '^N' history-substring-search-down
fi

# fzf key bindings and completion
if [[ -r /usr/share/fzf/key-bindings.zsh ]]; then
	source /usr/share/fzf/key-bindings.zsh
	[[ -r /usr/share/fzf/completion.zsh ]] && source /usr/share/fzf/completion.zsh
fi

# Keep syntax highlighting last.
if [[ -r /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
	source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
