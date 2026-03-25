#!/bin/zsh

if [[ "$(uname -s)" == "Darwin" ]] && type "${HOMEBREW_PREFIX}/bin/brew" >/dev/null 2>&1; then
  eval "$("${HOMEBREW_PREFIX}/bin/brew" shellenv)";
fi

if [ -d "$PATH:/Applications/Obsidian.app/Contents/MacOS" ]; then
  # Added by Obsidian
  export PATH="$PATH:/Applications/Obsidian.app/Contents/MacOS"
fi
