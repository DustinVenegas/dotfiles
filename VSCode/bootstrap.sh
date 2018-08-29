#!/bin/sh

symlink_dir_if_missing()
{
    SOURCE=$1
    DEST=$2

    if [ ! -d "$DEST" ]; then
        ln -s "$SOURCE" "$DEST"
    fi
}

install_macos_homebrew_deps()
{
    command -v brew > /dev/null || echo 'Expected brew command, but not found. Is Homebrew for MacOS installed?' >&2

    if [ ! "$(brew bundle check)" ]; then
        brew bundle
    fi
}

# TODO: Support XDG_CONFIG_HOME
SCRIPT_ROOT="$(dirname "${0}")"

# Symlink Directory
symlink_dir_if_missing "$SCRIPT_ROOT" "$HOME/Library/Application Support/Code/User/"

# Install software
install_macos_homebrew_deps

# Install VSCode Extensions
VSCODE_EXTENSIONS="EditorConfig.EditorConfig"
VSCODE_EXTENSIONS="$VSCODE_EXTENSIONS ms-vscode.csharp"
VSCODE_EXTENSIONS="$VSCODE_EXTENSIONS ms-vscode.PowerShell"
VSCODE_EXTENSIONS="$VSCODE_EXTENSIONS PeterJausovec.vscode-docker"
VSCODE_EXTENSIONS="$VSCODE_EXTENSIONS robertohuertasm.vscode-icons"
VSCODE_EXTENSIONS="$VSCODE_EXTENSIONS vscodevim.vim"
VSCODE_EXTENSIONS="$VSCODE_EXTENSIONS pivotal.vscode-concourse"
VSCODE_EXTENSIONS="$VSCODE_EXTENSIONS mauve.terraform"
VSCODE_EXTENSIONS="$VSCODE_EXTENSIONS timonwong.shellcheck"
VSCODE_EXTENSIONS="$VSCODE_EXTENSIONS ms-vscode.go"
VSCODE_EXTENSIONS="$VSCODE_EXTENSIONS davidanson.vscode-markdownlint"
VSCODE_EXTENSIONS="$VSCODE_EXTENSIONS yzhang.markdown-all-in-one"
#VSCODE_EXTENSIONS="$VSCODE_EXTENSIONS fcrespo82.markdown-table-formatter"


for ext in $VSCODE_EXTENSIONS; do
    code --install-extension "$ext"
done;
