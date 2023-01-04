#!/bin/env zsh

bindkey -e # emacs mode in zsh

setopt no_beep
setopt histignorealldups
setopt sharehistory

SAVEHIST=65535
HISTFILE=~/.zsh_history

# homebrew for linux envvars
if [ -d /home/linuxbrew/ ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Adds ~/.local/bin to PATH
if [ -d "$HOME/.local/bin" ] && [[ ! "$PATH" == *$HOME/.local/bin* ]]; then export PATH="$PATH:$HOME/.local/bin"; fi

# volta
if type volta >/dev/null 2>&1; then
    export VOLTA_HOME="$HOME/.volta"
    if [[ ! "$PATH" == *"$VOLTA_HOME"/bin* ]]; then export PATH="$VOLTA_HOME/bin:$PATH"; fi
fi

# default editor
if type vim >/dev/null 2>&1; then EDITOR=vim; fi
if type nvim >/dev/null 2>&1; then EDITOR=nvim; fi
export EDITOR

# ripgrep, Makes $HOME/.ripgreprc the default configuration.
if [ -f "$HOME/.ripgreprc" ]; then
    # RIPGREP_CONFIG_PATH is required for ripgrep to respect the config.
    export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
fi

# homebrew autocomplete
if type brew >/dev/null 2>&1; then
  # homebrew zsh environment
  if [ -d "$(brew --prefix)/share/zsh/site-functions" ]; then
    # FPATH must be declared before calling compinit for zsh.
    FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
  fi

  # node-version-manager
  if [ -d "$(brew --prefix nvm)" ]; then
    export NVM_DIR="$HOME/.nvm"

    nvmsh="$(brew --prefix)/opt/nvm/nvm.sh"
    [ -s "$nvmsh" ] && \. "$nvmsh"  # This loads nvm
    unset nvmsh

    # IMPORTANT: bash_completion also loads zsh as of 2022/06/30.
    bashCompletion="$(brew --prefix)/opt/nvm/etc/bash_completion"
    if [ -s "$bashCompletion" ]; then
        # shellcheck source=/dev/null
        source "$bashCompletion"
    fi
    unset bashCompletion
  fi
fi

if type zoxide >/dev/null 2>&1; then eval "$(zoxide init bash)"; fi

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

# .zshrc.local, to override any settings from this .zshrc file.
if [ -f "$HOME/.zshrc.local" ]; then
    # shellcheck source=/dev/null
    source "$HOME/.zshrc.local"
fi

# Use modern completion system
autoload -Uz compinit
compinit

if type oh-my-posh >/dev/null 2>&1; then
        promptVariation='.minimal'
        if [[ -n "${WT_SESSION}" ]]
        then
                promptVariation=''
        fi
        if [[ -n "${TERM_PROGRAM}" ]]
        then
                if [[ 'VSCode' == "${TERM_PROGRAM}" ]]
                then
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
  _dotnet_zsh_complete()
  {
    local completions=("$(dotnet complete "$words")")

    reply=( "${(ps:\n:)completions}" )
  }

  compctl -K _dotnet_zsh_complete dotnet
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