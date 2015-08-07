#
# .zshrc
# Last changed: Wed, 05 Nov 2014 21:31:21 -0800
#

#
# EXPORTS
#

# begin path with ~/bin directory so that homebrewed symlinks here are seen
# PATH might be better in a ~/.zshenv file but for now an export of it is
# included here
export PATH=$HOME/bin:$PATH
export EDITOR=vim
export VISUAL=vim


#
# COLOR
#

# All of these settings enable consistent coloring of the most frequently
# used parts of the CLI. For historical reasons 'ls', 'less', 'grep', and
# the completion menu all require separate color settings.

# Enable command line color
export CLICOLOR=1
# Define colors for the 'ls' command on BSD/Darwin
export LSCOLORS='exfxcxdxbxGxDxabagacad'
# Define colors for the zsh completion system
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=36;01:cd=33;01:su=31;40;07:sg=36;40;07:tw=32;40;07:ow=33;40;07:'

# The pager 'less' (the default pager for man-pages) depends on
# the (obsolete) TERMCAP library for color capabilities. Exporting
# the following parameters provides for colored man-page display.
export LESS_TERMCAP_mb=$'\E[01;31m'    # begins blinking = LIGHT_RED
export LESS_TERMCAP_md=$'\E[0;34m'     # begins bold = BLUE
export LESS_TERMCAP_me=$'\E[0m'        # ends mode = NO_COLOR
export LESS_TERMCAP_se=$'\E[0m'        # ends standout-mode = NO_COLOR
export LESS_TERMCAP_so=$'\E[00;47;30m' # begins standout-mode = REVERSE_WHITE
export LESS_TERMCAP_ue=$'\E[0m'        # ends underline = NO_COLOR
export LESS_TERMCAP_us=$'\E[01;32m'    # begins underline = LIGHT_GREEN

# The following provide color highlighing by default for GREP
# export GREP_COLOR='37;45'
export GREP_OPTIONS='--color=auto'


#
# COMPLETION SYSTEM
#

# The following lines were added by compinstall

zstyle ':completion:*' auto-description '%d'
zstyle ':completion:*' completer _complete _ignored _approximate
zstyle ':completion:*' group-name ''
zstyle ':completion:*' ignore-parents parent pwd .. directory
zstyle ':completion:*' insert-unambiguous true
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-prompt '%SAt %p: Hit TAB for more, or the character to insert%s'
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|[._-]=** r:|=**' 'l:|=* r:|=*'
zstyle ':completion:*' max-errors 1
zstyle ':completion:*' menu select=0
zstyle ':completion:*' original true
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' verbose true
zstyle :compinstall filename '/Users/ddeconde/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall


#
# OPTIONS
#

# Directory
setopt AUTO_CD              # auto changes to a directory without typing cd
setopt AUTO_PUSHD           # push the old directory onto the stack on cd
setopt PUSHD_IGNORE_DUPS    # do not store duplicates in the stack
setopt PUSHD_SILENT         # do not print directory stack after pushd/popd
setopt PUSHD_TO_HOME        # push to home when no argument is given
setopt CDABLE_VARS          # enable cd to a path stored in a variable

# Completion
setopt ALWAYS_TO_END        # move cursor to the end of a completed word
setopt AUTO_NAME_DIRS       # auto add variable-stored paths to ~ list
setopt COMPLETE_IN_WORD     # complete from both ends of a word
unset LIST_BEEP             # do not beep when completion fails

# Expansion & Globbing
setopt BRACE_CCL          # allow brace character class list expansion
setopt EXTENDED_GLOB      # use extended globbing syntax
unsetopt CASE_GLOB        # allow case-insensitive globbing

# History
HISTFILE=~/.histfile         # the path to the history file
HISTSIZE=1000                # size of the internal shell history
SAVEHIST=1000                # size (in events) of the the history file
# SHARE_HISTORY duplicates the effect of INC_APPEND_HISTORY
setopt SHARE_HISTORY         # share history between all sessions
setopt EXTENDED_HISTORY      # write HISTFILE as ':start:elapsed;command'
setopt HIST_IGNORE_DUPS      # do not rerecord a duplicate of an event
setopt HIST_IGNORE_ALL_DUPS  # delete old event when new is a duplicate
setopt HIST_SAVE_NO_DUPS     # do not write duplicate events to HISTFILE
setopt HIST_FIND_NO_DUPS     # do not display a previously found event
setopt HIST_IGNORE_SPACE     # do not record an event starting with a space
setopt HIST_REDUCE_BLANKS    # remvove extra spaces when saving to history
setopt HIST_VERIFY           # do not immediately execute history expansion
unsetopt HIST_BEEP           # no beep when accessing non-existent history

# Input/Output
unsetopt CLOBBER        # do not overwrite existing files with > and >>
                        # use >! and >>! to bypass this option
unsetopt FLOW_CONTROL   # disable start/stop characters in shell editor
unsetopt MAIL_WARNING   # disable warnings about mail file changes

# Job Control
setopt AUTO_RESUME      # resume existing job rather than create a new one
unsetopt BG_NICE        # don't run all background jobs at a lower priority
unsetopt HUP            # don't kill jobs on shell exit
unsetopt CHECK_JOBS     # don't report on jobs when shell exit
unsetopt NOTIFY         # report status of background jobs immediately
setopt LONG_LIST_JOBS   # list jobs in the long format by default

# Prompts
setopt PROMPT_SUBST      # allow for more extensive expansion in prompts
setopt TRANSIENT_RPROMPT # right prompt does not persist

# Scripts & Functions
setopt MULTIOS              # write to multiple descriptors

# ZLE
setopt COMBINING_CHARS    # merge zero-length marks with base characters


#
# VCS_INFO
#

autoload -Uz vcs_info

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:git:*' formats '%u%c%{%F{green}%}%b%{%f%}'
zstyle ':vcs_info:git:*' stagedstr '%{%F{yellow}%}+%{%f%} '
zstyle ':vcs_info:git:*' unstagedstr '%{%F{red}%}*%{%f%} '

precmd() {
    vcs_info
}


#
# PROMPT
#

# hostname: cwd [exit status] %
PROMPT='%{%F{blue}%}%m:%{%f%} ${${PWD/#$HOME/~}:t} %(?..%{%F{yellow}%}%? %{%f%})%{%F{white}%}%#%{%f%} '

# Righthand prompt displays vcs_info: [(un)staged changes] branch
RPROMPT='${vcs_info_msg_0_}'


#
# ZLE
#

# Use default Emacs-style keybindings even when EDITOR is set to vim
bindkey -e

# allow editing the command line within EDITOR
# Enable Ctrl-x-e (or v in Vim command mode) to edit command line
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^xe' edit-command-line
bindkey '^x^e' edit-command-line
bindkey -M vicmd v edit-command-line

# get into vi command mode just by hitting Esc; 'i' gets back to Emacs mode
bindkey '^[' vi-cmd-mode

# Treat these characters as part of a word.
# WORDCHARS='*?_-.[]~&;!#$%^(){}<>'

# Remove '/' from WORDCHARS to treat each part of a path as a separate word
WORDCHARS=${WORDCHARS/\/}


#
# HISTORY SUBSTRING SEARCH
#

# If on OSX Homebrew will put zsh-history-substring-search here:
ZSH_HISTORY_SUBSTRING_SEARCH=\
  "/usr/local/opt/zsh-history-substring-search/zsh-history-substring-search.zsh"

# If on Linux install zsh-history-substring-search here:
ZSH_HISTORY_SUBSTRING_SEARCH_ALT=\
  "/usr/local/zsh-history-substring-search/zsh-history-substring-search.zsh"

if [[ -f ${ZSH_HISTORY_SUBSTRING_SEARCH} ]]; then
  source ${ZSH_HISTORY_SUBSTRING_SEARCH}
elif [[ -f ${ZSH_HISTORY_SUBSTRING_SEARCH_ALT} ]]; then
  source ${ZSH_HISTORY_SUBSTRING_SEARCH_ALT}
else
  print "No zsh-history-substring-search plugin found.\n"
fi


# bind UP and DOWN arrow keys
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# bind P and N for EMACS mode
bindkey -M emacs '^P' history-substring-search-up
bindkey -M emacs '^N' history-substring-search-down

# bind k and j for VI mode
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down


#
# ALIASES
#

alias ls='ls -Gh'
alias la='ls -aGh'
alias ll='ls -GFhl'
alias lla='ls -aGFhl'
alias mvim='mvim -v'

# Use Homebrewed versions of some programs
# alias git='/usr/local/bin/git'
# alias vim='/usr/local/bin/vim'

alias -g ...='../..'
alias -g ....='../../..'
alias -g C='2>&1 | cat'
alias -g DN=/dev/null
alias -g EG='|& egrep'
alias -g EH='|& head'
alias -g EL='|& less'
alias -g ELS='|& less -S'
alias -g ETL='|& tail -20'
alias -g ET='|& tail'
alias -g F=' | fmt -'
alias -g G='| egrep'
alias -g H='| head'
alias -g HL='|& head -20'
alias -g LL='2>&1 | less'
alias -g L="| less"
alias -g LS='| less -S'
alias -g M='| more'
alias -g NE="2> /dev/null"
alias -g NS='| sort -n'
alias -g NUL="> /dev/null 2>&1"
alias -g RNS='| sort -nr'
alias -g S='| sort'
alias -g TL='| tail -20'
alias -g T='| tail'
alias -g US='| sort -u'
alias -g WC='| wc -l'
alias -g X0G='| xargs -0 egrep'
alias -g X0='| xargs -0'
alias -g XG='| xargs egrep'
alias -g X='| xargs'


#
# LOCAL
#

# If a zshrc_local file is available then source that too
if [[ -f ~/.zshrc_local ]]; then
    source ~/.zshrc_local
fi
