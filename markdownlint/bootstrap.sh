#!/bin/sh

symlink_if_missing()
{
    SOURCE=$1
    DEST=$2

    if [ ! -f "$DEST" ]; then
        ln -s "$SOURCE" "$DEST"
    else
	echo "Already exists $SOURCE -> $DEST"
    fi
}

SCRIPT_DIR="$(cd "$(dirname "${0}")" || exit; pwd)"

# Symlink configurations, if they don't already exist
symlink_if_missing "$SCRIPT_DIR/markdownlint.json" "$HOME/.markdownlintrc"
