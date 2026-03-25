#!/bin/env zsh

# zmodload zsh/zprof

setopt histignoredups # ignore preceding duplicates
#setopt histignorealldups
setopt sharehistory
setopt autopushd
# ignore duplicate pushd
setopt pushdignoredups # Do not store duplicates in the stack.
setopt pushdsilent # Do not print the directory stack after pushd or popd.
setopt histverify # Confirm history expansion before executing

setopt autocd
setopt ignoreeof # do not exit the shell on Ctrl-D
setopt autolist
setopt recexact # select exact matches in tab completion

bindkey -e # emacs mode in zsh

# Sets HOMEBREW_PREFIX and associated ENVVARs for homebrew
if [[ ! "${HOMEBREW_PREFIX}" ]]; then
    case "$(uname -s)" in
        Linux)
            if [ -f /home/linuxbrew/.linuxbrew/bin/brew ]; then
                eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)";
            fi
            ;;
        Darwin)
            # Do nothing; homebrew is initialized in .zprofile on macOS
            ;;
        *)
            echo "Error Locating HOMEBREW_PREFIX: Unknown OS type: $(uname -s)" 1>&2
            ;;
    esac
fi

# Local settings to override this file.
if [ -f "$HOME/.zshrc.local" ]; then
  source "$HOME/.zshrc.local"
fi

if [[ -o interactive ]]; then
  # Autoloads that compinit will discover (completion functions)
  # Includes dotfiles zsh completions in the zsh file search path.
  fpath=("${XDG_CONFIG_HOME}/zsh-vme/completions" $fpath)

  if [[ ! "$fpath" == *"$HOME/.docker/completions"* ]] && [ -d "$HOME/.docker/completions" ]; then
    fpath=("$HOME/.docker/completions" $fpath)
  fi

  # Use modern completion system 'compinit'.
  autoload -Uz compinit
  compinit

  # Enable editing a command-line with $EDITOR using Ctrl+X Ctrl+E
  autoload -Uz edit-command-line
  zle -N edit-command-line
  bindkey "^X^E" edit-command-line

  # Prompt
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

  # Interactive customizations after 'compinit'.
  if [ -f "${XDG_CONFIG_HOME}/zsh-vme/interactive.sh" ]; then
    source "${XDG_CONFIG_HOME}/zsh-vme/interactive.sh"
  fi

  # Aliases for interactive shells
  if [ -f "${XDG_CONFIG_HOME}/zsh-vme/aliases.sh" ]; then
    source "${XDG_CONFIG_HOME}/zsh-vme/aliases.sh"
  fi
fi

# zprof;
