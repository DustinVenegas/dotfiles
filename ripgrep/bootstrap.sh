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
symlink_if_missing "$SCRIPT_DIR/ripgreprc" "$HOME/.ripgreprc"

# OF-Specific Smybolic Links
OS="`uname`"
case $OS in
    'Linux')
        sed 's/#.*//' ubuntu-installs.txt | xargs sudo apt-get install
        ;;
    'Darwin')
        brew bundle
        ;;
    *)
        echo "WARNNG: gitconfig_os type is missing, $OSTYPE"
        ;;
esac
