#!/bin/zsh

if [ -d "${HOMEBREW_PREFIX}/share/zsh-you-should-use" ]; then
  # you-should-use plugin
  source "${HOMEBREW_PREFIX}/share/zsh-you-should-use/you-should-use.plugin.zsh"
fi

if [ -d "${HOMEBREW_PREFIX}/share/zsh-syntax-highlighting" ]; then
  # zsh-syntax-highlighting
  # Must be the last line in the file.
  source "${HOMEBREW_PREFIX}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi