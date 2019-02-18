#!/bin/sh

symlink_if_missing()
{
    SOURCE=$1
    DEST=$2

    if [ ! -f "$DEST" ]; then
        ln -s "$SOURCE" "$DEST"
    else
	echo "Source already exists at Dest $SOURCE -> $DEST"
    fi
}

# TODO: Support XDG_CONFIG_HOME
SCRIPT_DIR="$(cd "$(dirname "${0}")"; pwd)"

# Symlink configurations, if they don't already exist
symlink_if_missing "$SCRIPT_DIR/bashrc" "$HOME/.bashrc"
symlink_if_missing "$SCRIPT_DIR/bash_profile" "$HOME/.bash_profile"
