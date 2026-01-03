#!/bin/zsh

getSourceLocations () {
  find -L "$HOME/Source" -mindepth 1 -maxdepth 3 -type d | grep -v '\.git'
}

if type fzf >/dev/null 2>&1; then
  export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"

  editSourceLocation () { $EDITOR "$(getSourceLocations | fzf)" || return; }
  getSourceLocation () { getSourceLocations | fzf || return; }
  setSourceLocation () { cd "$(getSourceLocations | fzf)" || return; }
  pushSourceLocation () { pushd "$(getSourceLocations | fzf)" || return; }

  alias esl=editSourceLocation
  alias gsl=getSourceLocation
  alias ssl=setSourceLocation
  alias psl=pushSourceLocation
fi
