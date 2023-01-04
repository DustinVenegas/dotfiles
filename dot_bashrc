#!/usr/bin/env bash

# bash
HISTCONTROL=ignoreboth  # Ignore duplicate commands, or ones prefixed with a space
HISTSIZE=65535 # Keep lots of history. Default, 500

# XDG bin directory
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# ripgrep
if [ -f "$HOME/.ripgreprc" ]; then
    export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
fi

# homebrew for linux
if [ -d /home/linuxbrew/ ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# volta
if type volta >/dev/null 2>&1; then
    VOLTA_HOME="$HOME/.volta"
    PATH="$VOLTA_HOME/bin:$PATH"
    export VOLTA_HOME
fi

# Linux Utilities
if type vim >/dev/null 2>&1; then EDITOR=vim; fi
if type nvim >/dev/null 2>&1; then EDITOR=nvim; fi
export EDITOR

# homebrew autocomplete
if type brew >/dev/null 2>&1; then
    for completion_file in "$(brew --prefix)"/etc/bash_completion.d/*; do
        # shellcheck source=/dev/null
        source "$completion_file"
    done

    # node-version-manager
    if [ -d "$(brew --prefix nvm)" ]; then
        export NVM_DIR="$HOME/.nvm"

        nvmsh="$(brew --prefix)/opt/nvm/nvm.sh"
        if [ -s "$nvmsh" ]; then
            # shellcheck source=/dev/null
            source "$nvmsh"
        fi
        unset nvmsh

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
        source "$fzfShellDir/completion.bash" 2> /dev/null
    fi

    # shellcheck source=/dev/null
    source "$fzfShellDir/key-bindings.bash"
fi
unset fzfShellDir

# .bashrc.local, to override any settings from this .bashrc file.
if [ -f "$HOME/.bashrc.local" ]; then
    # shellcheck source=/dev/null
    source "$HOME/.bashrc.local"
fi

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

    eval "$(oh-my-posh --init --shell bash --config ~/.dotfiles-prompt"$promptVariation".omp.json)"
fi

if type dotnet >/dev/null 2>&1; then
    # bash parameter completion for the dotnet CLI
    function _dotnet_bash_complete()
    {
    local cur="${COMP_WORDS[COMP_CWORD]}" IFS=$'\n'
    local candidates

    read -d '' -ra candidates < <(dotnet complete --position "${COMP_POINT}" "${COMP_LINE}" 2>/dev/null)

    read -d '' -ra COMPREPLY < <(compgen -W "${candidates[*]:-}" -- "$cur")
    }
    complete -f -F _dotnet_bash_complete dotnet
fi

getSourceLocations () {
    find -L "$HOME/Source" -mindepth 1 -maxdepth 3 -type d | grep -v '\.git'
}

editSourceLocation () { $EDITOR "$(getSourceLocations | fzf)" || return; }
getSourceLocation () { "$(getSourceLocations | fzf)" || return; }
setSourceLocation () { cd "$(getSourceLocations | fzf)" || return; }
pushSourceLocation () { pushd "$(getSourceLocations | fzf)" || return; }

alias esl=editSourceLocation
alias gsl=getSourceLocation
alias ssl=setSourceLocation
alias psl=pushSourceLocation