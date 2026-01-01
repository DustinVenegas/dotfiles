#!/bin/env zsh

setopt histignorealldups
setopt sharehistory

bindkey -e # emacs mode in zsh

# homebrew for linux envvars
if [ -d /home/linuxbrew/ ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# homebrew autocomplete
if type brew >/dev/null 2>&1; then
  # homebrew zsh environment
  if [ -d "${HOMEBREW_PREFIX}/share/zsh/site-functions" ]; then
    if [[ ! "$fpath" == *${HOMEBREW_PREFIX}/share/zsh/site-functions* ]]; then
      fpath=("${HOMEBREW_PREFIX}/share/zsh/site-functions" $fpath)
    fi
    export fpath
  fi
fi

# if type zoxide >/dev/null 2>&1; then eval "$(zoxide init zsh)"; fi

fzfShellDir="/usr/share/doc/fzf/examples" # Default on Ubuntu 20.04
if type brew >/dev/null 2>&1; then

  fzfShellDir="$(brew --prefix)/opt/fzf/shell"

  if [[ ! "$PATH" == *"$(brew --prefix)"/opt/fzf/bin* ]]; then
    # Append fzf/bin to the PATH since homebrew does not.
    PATH="$PATH:$(brew --prefix)/opt/fzf/bin"
    export PATH
  fi
fi
if [ -d "$fzfShellDir" ]; then
  if [[ $- == *i* ]]; then
    # shellcheck source=/dev/null
    source "$fzfShellDir/completion.zsh" 2> /dev/null
  fi

  # shellcheck source=/dev/null
  source "$fzfShellDir/key-bindings.zsh"
fi
unset fzfShellDir

# Local settings to override this file.
if [ -f "$HOME/.zshrc.local" ]; then
  source "$HOME/.zshrc.local"
fi

if [[ -o interactive ]]; then

  # Use modern completion system
  autoload -Uz compinit
  compinit

  autoload -Uz edit-command-line
  zle -N edit-command-line
  bindkey "^X^E" edit-command-line

  source /opt/homebrew/share/zsh-you-should-use/you-should-use.plugin.zsh

  if type oh-my-posh >/dev/null 2>&1; then
    promptVariation='.minimal'
    if [[ -n "${WT_SESSION}" ]]; then
      promptVariation=''
    fi
    if [[ -n "${TERM_PROGRAM}" ]]; then
      if [[ 'VSCode' == "${TERM_PROGRAM}" ]]; then
        promptVariation=''
      fi
    fi
    eval "$(oh-my-posh --init --shell zsh --config ~/.dotfiles-prompt$promptVariation.omp.json)"
  else
    autoload -Uz promptinit
    promptinit
    prompt adam1
  fi
  
  if type dotnet >/dev/null 2>&1; then
    # zsh parameter completion for the dotnet CLI
    _dotnet_zsh_complete() {
      local completions=("$(dotnet complete "$words")")
      reply=( "${(ps:\n:)completions}" )
    }
    compctl -K _dotnet_zsh_complete dotnet
  fi
fi

getSourceLocations () {
  find -L "$HOME/Source" -mindepth 1 -maxdepth 3 -type d | grep -v '\.git'
}

editSourceLocation () { $EDITOR "$(getSourceLocations | fzf)" || return; }
getSourceLocation () { getSourceLocations | fzf || return; }
setSourceLocation () { cd "$(getSourceLocations | fzf)" || return; }
pushSourceLocation () { pushd "$(getSourceLocations | fzf)" || return; }

alias esl=editSourceLocation
alias gsl=getSourceLocation
alias ssl=setSourceLocation
alias psl=pushSourceLocation

# Added by LM Studio CLI (lms)
if type lms >/dev/null 2>&1; then
  export PATH="$PATH:/Users/dustin/.cache/lm-studio/bin"
fi
# End of LM Studio CLI section

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/dustin/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions

if [[ -o interactive ]]; then
  # zsh-syntax-highlighting
  # Must be the last line in the file.
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
