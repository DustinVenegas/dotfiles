SAVEHIST=65535
HISTFILE=~/.zsh_history

# Add ~/.local/bin to PATH
if [[ -d "$HOME/.local/bin" ]] && [[ ! "$PATH" == *$HOME/.local/bin* ]]; then
    export PATH="$PATH:$HOME/.local/bin";
fi

if [ -f "$HOME/.ripgreprc" ]; then
    # RIPGREP_CONFIG_PATH is required for ripgrep to respect the config.
    export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
fi

# default editor
if type nvim >/dev/null 2>&1; then
    export EDITOR=nvim;
elif type vim >/dev/null 2>&1; then
    export EDITOR=vim;
elif type code >/dev/null 2>&1; then
    export EDITOR=code;
fi

[[ -f ~/.zshenv.local ]] && source ~/.zshenv.local