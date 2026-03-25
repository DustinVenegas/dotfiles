#!/bin/zsh

zmodload zsh/complist

zstyle ':completion:*' menu select # Allow you to select in a menu
zstyle ':completion:*' group yes
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:*:*:*:descriptions' format '%F{green}-- %d --%f'
zstyle ':completion:*:*:*:*:corrections' format '%F{yellow}!- %d (errors: %e) -!%f'
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
zstyle ':completion:*' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*' group-name '' # Group compltion entries by type
zstyle ':completion:*' verbose yes

# Man pages with different numbers as individual sections for completion.
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.(^1*)' insert-sections true

# Show options for 'cd' on '-<tab>'.
# Complete historical directories using: 'cd ~+<TAB>'
zstyle ':completion:*' complete-options true

# Completers for zsh that tries extensions, regular completion, then approximate matches.
zstyle ':completion:*' completer _extensions _complete _approximate

zstyle ':completion:*:default' list-colors ${(s.:.)LSCOLORS}
zstyle ':completion:*:*:cd:*' tag-order 'local-directories directory-stack path-directories'
zstyle ':completion:*:*:-command-:*:*' group-order 'aliases builtins functions commands'

autoload -Uz zsh/terminfo

# help system with context in zsh
# DESCRIPTION:
#  Use a context aware help system that can search for help on functions, builtins, and commands.
# TRIGGER:
#   ESC-H, ESC-h, ALT-H, ALT-h
#   (Search help for the current command or word under the cursor))
# that can resolve `get-help history`
# if macos
if [[ "$(uname -s)" == "Darwin" ]]; then
  HELPDIR="/usr/share/zsh/$(zsh --version | cut -d' ' -f2)/help"
fi
unalias run-help
autoload run-help \
  run-help-git \
  run−help−ip \
  run−help−openssl \
  run−help−sudo

if (( $+commands[npm] )); then
  # Obtained from the "type compdef" output of:
  # > npm completion
  _npm_completion() {
    local si=$IFS
    compadd -- $(COMP_CWORD=$((CURRENT-1)) \
                  COMP_LINE=$BUFFER \
                  COMP_POINT=0 \
                  npm completion -- "${words[@]}" \
                  2>/dev/null)
    IFS=$si
  }
  compdef _npm_completion npm
fi

if (( $+commands[zoxide] )); then
    eval "$(zoxide init zsh)" 
fi

if (( $+commands[fzf] )) &> /dev/null; then
  # Set up fzf key bindings and fuzzy completion
  source <(fzf --zsh)
fi

if (( $+commands[gcloud] )) && \
  (( $+functions[compdef] )) && \
  [[ -d "${HOMEBREW_PREFIX}/share/google-cloud-sdk" ]]; then
    source "${HOMEBREW_PREFIX}/share/google-cloud-sdk/completion.zsh.inc"
fi

if [ -d "${HOMEBREW_PREFIX}/share/zsh-you-should-use" ]; then
  # you-should-use plugin
  source "${HOMEBREW_PREFIX}/share/zsh-you-should-use/you-should-use.plugin.zsh";
fi

if [ -d "${HOMEBREW_PREFIX}/share/zsh-syntax-highlighting" ]; then
  # zsh-syntax-highlighting
  # Must be the last line in the file.
  source "${HOMEBREW_PREFIX}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
fi
