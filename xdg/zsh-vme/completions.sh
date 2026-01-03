#!/bin/zsh

# zoxide
if zoxide >/dev/null 2>&1 && ! type z >/dev/null 2>&1; then
  eval "$(zoxide init zsh)";
fi

# docker
if [[ ! "$fpath" == *"$HOME/.docker/completions"* ]] && \
  [ -d "$HOME/.docker/completions" ]; then
  fpath=("$HOME/.docker/completions" $fpath)
fi

# fzf
fzfShellDir="/usr/share/doc/fzf/examples" # Default on Ubuntu 20.04
if [[ "${HOMEBREW_PREFIX}" != "" ]] && \
  [[ -d "${HOMEBREW_PREFIX}/opt/fzf/shell" ]]; then
  fzfShellDir="${HOMEBREW_PREFIX}/opt/fzf/shell"
fi
if [ -d "$fzfShellDir" ]; then
  # Check if the shell is running in interactive mode by testing if the 'i' flag is set in $-
  # $- contains all shell option flags; 'i' indicates an interactive shell
  # This condition is true only when the script is being run interactively, not in batch/non-interactive mode
  if [[ $- == *i* ]]; then
    # shellcheck source=/dev/null
    source "$fzfShellDir/completion.zsh"
  fi

  # shellcheck source=/dev/null
  source "$fzfShellDir/key-bindings.zsh"
fi
unset fzfShellDir
