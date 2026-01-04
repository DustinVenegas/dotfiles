# .zshenv is sourced for all shell invocations
# .zshenv is called by /etc/zshenv

SAVEHIST=65535
HISTFILE=~/.zsh_history

# Set XDG_CONFIG_HOME if not already set
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CONFIG_HOME

# Add ~/.local/bin to PATH
if [[ -d "$HOME/.local/bin" ]] \
&& [[ ! "$PATH" == *"$HOME/.local/bin"* ]]; then
    export PATH="$PATH:$HOME/.local/bin";
fi

if [[ ! "${RIPGREP_CONFIG_PATH}" ]] \
&& [[ -f "$HOME/.ripgreprc" ]]; then
    # RIPGREP_CONFIG_PATH is required for ripgrep to respect the config.
    export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
fi

if [[ -o rcs ]]; then
    # default editor when RCs are read
    if type nvim >/dev/null 2>&1; then
        export EDITOR=nvim;
    elif type vim >/dev/null 2>&1; then
        export EDITOR=vim;
    elif type code >/dev/null 2>&1; then
        export EDITOR=code;
    fi
else
    export EDITOR=vim;
fi

if [[ -f "$HOME/.zshenv.local" ]]; then
    source "$HOME/.zshenv.local"
fi

# Set HOMEBREW_PREFIX based on OS if not already set.
case "$(uname -s)" in
    Darwin)
        # Set HOMEBREW_PREFIX if not already set
        HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-/opt/homebrew}"
        ;;
    Linux)
        # Set HOMEBREW_PREFIX if not already set
        HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-/home/linuxbrew/.linuxbrew}"
        ;;
    *)
        echo "Error Locating HOMEBREW_PREFIX: Unknown OS type: $(uname -s)" 1>&2
        ;;
esac

if type "${HOMEBREW_PREFIX}/bin/brew" >/dev/null 2>&1; then
    export HOMEBREW_PREFIX
fi

if [[ -o rcs ]] && [[ -d "${HOMEBREW_PREFIX}/share/google-cloud-sdk" ]]; then
    source "${HOMEBREW_PREFIX}/share/google-cloud-sdk/path.zsh.inc"
fi