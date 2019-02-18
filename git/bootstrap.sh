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

write_template_if_missing()
{
    SOURCE=$1
    DEST=$2

    if [ ! -f "$DEST" ]; then
        cp "$SOURCE" "$DEST"
    else
	echo "Already exists $SOURCE -> $DEST"
    fi
}


# TODO: Support XDG_CONFIG_HOME
SCRIPT_DIR="$(cd "$(dirname "${0}")"; pwd)"

# Symlink configurations, if they don't already exist
symlink_if_missing "$SCRIPT_DIR/gitconfig" "$HOME/.gitconfig"
symlink_if_missing "$SCRIPT_DIR/gitignore" "$HOME/.gitignore"
symlink_if_missing "$SCRIPT_DIR/gitattributes" "$HOME/.gitattributes"

# OF-Specific Smybolic Links
OS="`uname`"
case $OS in
    'Linux')
        symlink_if_missing "$SCRIPT_DIR/gitconfig_os_ubuntu" "$HOME/.gitconfig_os"
        ;;
    'Darwin')
        symlink_if_missing "$SCRIPT_DIR/gitconfig_os_macos" "$HOME/.gitconfig_os"
        ;;
    *)
        echo "WARNNG: gitconfig_os type is missing, $OSTYPE"
        ;;
esac

# Write the local template if it doesn't exist
write_template_if_missing "$SCRIPT_DIR/gitconfig_local.template" "$HOME/.gitconfig_local"
