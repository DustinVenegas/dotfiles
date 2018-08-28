#!/bin/sh

symlink_if_missing()
{
    SOURCE=$1
    DEST=$2

    if [ ! -f "$DEST" ]; then
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

write_template_if_missing()
{
    if [ ! -f "$DEST" ]; then
        cp "$SOURCE" "$DEST"
    fi
}


# TODO: Support XDG_CONFIG_HOME
SCRIPT_DIR="$(dirname "${0}")"

# Symlink configurations, if they don't already exist
symlink_if_missing "$SCRIPT_DIR/gitconfig" "$HOME/.gitconfig"
symlink_if_missing "$SCRIPT_DIR/gitconfig_os_macos" "$HOME/.gitconfig_os"
symlink_if_missing "$SCRIPT_DIR/gitignore" "$HOME/.gitignore"
symlink_if_missing "$SCRIPT_DIR/gitattributes" "$HOME/.gitattributes"

# Write the local template if it doesn't exist
write_template_if_missing "$SCRIPT_DIR/gitconfig_local.template" "$HOME/.gitconfig_local"

# Install software
install_macos_homebrew_deps
