#!/bin/zsh

if [[ "$(uname -s)" == "Darwin" ]] && type "${HOMEBREW_PREFIX}/bin/brew" >/dev/null 2>&1; then
  eval "$("${HOMEBREW_PREFIX}/bin/brew" shellenv)";
fi
