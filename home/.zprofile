if [[ "$(uname -s)" == "Darwin" ]] && [[ -f ""]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
