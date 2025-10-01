#!/bin/sh
# dotfiles.sh - Configures a consistent user-profile 
#
# DESCRIPTION
# Sets symlinks in HOME, XDG_CONFIG_HOME, and XDG_DATA_HOME to configure a user-
# profile for this dotfiles repsitory.
#
# USAGE:
# ./dotfiles.sh [OPTIONS]
#
# EXAMPLE - List status of all files.
# ./dotfiles --all
#
# EXAMPLE - Test changes in ./test-data instead of HOME directories.
# ./dotfiles --local --all --write
#
# EXAMPLE - Write Changes (excludes conflicts)
# ./dotfiles --write
#
# EXAMPLE - Forcefully Write Changes (includes conflicts)
# ./dotfiles --write --force
#
# Dotfiles are configuration files 
# Dotfiles manages symlinks in HOME, XDG_CONFIG_HOME, and XDG_DATA_HOME.
# 

HOME_SRC="home"
XDG_SRC="xdg"
DATA_SRC="local"

if [ -z "$HOME" ] || [ ! -d "$HOME" ]; then
    echo "Error: HOME is not set or does not exist: $HOME"
    exit 1
fi
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

SCRIPT_ROOT=$(cd -- "$(dirname -- "$0")" && pwd)

WRITE=
STATUS=1
CONFIG=
FORCE=
HELP=
VERBOSE=1
while :; do
    case $1 in
        -h|-\?|--help)   # Call a "show_help" function to display a synopsis, then exit.
            HELP=1
            ;;
        -f|--force)
			FORCE=1
            ;;
        -W|--write)
			WRITE=1
            STATUS=$((STATUS - 1))
            ;;
        -c|--config)
            CONFIG=1
            ;;
        -s|--status)
            STATUS=$((STATUS + 1))
            ;;
        -v|--verbose)
            VERBOSE=$((VERBOSE + 1)) # Each -v argument adds 1 to verbosity.
            ;;
        -l|--local)
            local_dir="$SCRIPT_ROOT/test-data"
            HOME="$local_dir/home"
            XDG_CONFIG_HOME="$local_dir/.config"
            XDG_DATA_HOME="$local_dir/.local/share"

            mkdir -p "$HOME" "$XDG_CONFIG_HOME" "$XDG_DATA_HOME"
            ;;
        --)              # End of all options.
            shift
            break
            ;;
        -?*)
            printf 'Unknown option (ignored): %s\n' "$1" >&2
			exit 1
            ;;
        *)               # Default case: If no more options then break out of the loop.
            break
    esac

    shift
done

show_help() {
    cat << EOF
dotfiles.sh - Configures a user-profile for a dotfiles configuration.

Configure a user-profile for this dotfiles repository by mapping symlinks
from directories in this repository to destination directories.

Options:
    -h|--help 	    Show this help message.
    -W|--write 	    Write changes to the filesystem.
    -f|--force 	    Force changes to the filesystem.
    -v|--verbose	Adds verbosity to output.

EOF
}

show_config() {
    cat << EOF
Directory Map:
    HOME:        $HOME -> $HOME_SRC
    XDG_CONFIG:  $XDG_CONFIG_HOME -> $XDG_SRC
    DATA:        $XDG_DATA_HOME -> $DATA_SRC

Config:
    Write:       $WRITE
    Force:       $FORCE
    Verbose:     $VERBOSE
    Variation:   $(variation_string)

EOF
}

warn() { printf "WARN: %s\n" "$1" >&3; }
logn() { [ $VERBOSE -ge "$1" ] && printf "%s\n" "$2" >&3; }
log() { logn 0 "$1"; }

variation_string() {
    VARIATION=unix
    if [ "$(uname -s)" = "Darwin" ]; then VARIATION=darwin; fi
    echo "$VARIATION"
}

# resolve_locallink outputs a matching dotfile path or the last path in a symlink chain.
resolve_locallink() {
    target=$1
    value=$2

    while [ -L "$target" ]; do
        if [ "$target" = "$value" ]; then
            break
        fi

        target=$(readlink "$target")
        # target=$(ls -ld "$target" | awk '{print $NF}')
    done

    echo "$target"
}

# Function to create symlinks
map_symlinks() {
    src_dir=$1
    target_dir=$2

    if [ ! -d "$src_dir" ]; then
        warn "Source directory does not exist: $src_dir"
        return 1
    fi
    if [ ! -d "$target_dir" ]; then
        warn "Target directory does not exist: $target_dir"
        return 1
    fi

    # Iterate over the files in the source directory
    find "$src_dir" -mindepth 1 -maxdepth 1 | while read -r src_path; do
        # Skip the current directory (.) and parent directory (..)
        [ "$src_path" = "$src_dir/." ] || [ "$src_path" = "$src_dir/.." ] && continue

        # Define Paths
        target_path="$target_dir/$(basename "$src_path")"
        full_src_path="$SCRIPT_ROOT/$src_path"
        locallink="$(resolve_locallink "$target_path" "$full_src_path")"

        should_write=
        phrase=
        if [ ! -e "$target_path" ]; then
            phrase="NEW"
            locallink="Missing"
            should_write=1
        elif [ -e "$target_path" ] && [ ! -L "$target_path" ]; then
            phrase="CONFLICT"
            should_write=0
        elif [ -e "$target_path" ] && [ "$locallink" = "$full_src_path" ]; then
            phrase="VALID"
            should_write=0
        elif [ -e "$target_path" ] && [ "$locallink" != "$full_src_path" ]; then
            phrase="OUTDATED"
            should_write=1
        else
            phrase="UNKNOWN"
            should_write=0
        fi

        forced=
        if [ "$should_write" = 0 ] && [ $FORCE ]; then
            forced='(FORCE)'
            should_write=1
        fi

        action=
        if [ "$should_write" = "1" ]; then
            action="WRITE"
        elif [ "$should_write" = "0" ]; then
            action="SKIP"
        else
            action="UNKNOWN"
        fi

        echo "${action:-UNDEF} ${phrase:-UNDEF}" "${target_path:-UNDEF}" "${locallink:-UNDEF}" "${full_src_path:-UNDEF}" "${should_write:-UNDEF}" "${forced:-UNDEF}";
    done
}

status() {
    while read -r action phrase target_path locallink full_src_path should_write forced; do
        if [ $VERBOSE -le 2 ]; then
            echo "$action $phrase $target_path $(echo "$forced" | sed 's/UNDEF//')"
        else
            echo "$action $phrase $target_path $(echo "$forced" | sed 's/UNDEF//') $full_src_path $(echo "$locallink" | sed 's/Missing//')"
        fi
    done
}

write_symlinks() {
    while read -r action phrase target_path locallink full_src_path should_write forced; do
        if [ "$should_write" = "1" ] && [ $WRITE ]; then
            rm -f "$target_path" # Remove existing file to prevent nested symlinks
            ln -sf "$full_src_path" "$target_path"
            echo "$action $phrase $target_path $(echo "$forced" | sed 's/UNDEF//')"
        elif [ "$should_write" = "0" ]; then
            logn 3 "SKIP $target_path"
        else
            echo "UNK_ACTION '$should_write' '$WRITE' '$target_path' '$full_src_path'"
        fi
    done
}

main() {
    if [ $HELP ]; then
        show_help
        exit 1
    fi
    
    if [ $CONFIG ]; then
        show_config;
        exit 1
    fi

    exec 3>&1

    # Environmental prerequisites
    [ ! -d "$HOME" ] && mkdir -p "$HOME";
    [ ! -d "$XDG_CONFIG_HOME" ] && mkdir -p "$XDG_CONFIG_HOME";
    [ ! -d "$XDG_DATA_HOME" ] && mkdir -p "$XDG_DATA_HOME";

    # Create symlinks for internal items
    ln -sf "$(pwd)/xdg/git/.gitconfig_os_$(variation_string)" "home/.gitconfig_os"

    # Maps symlinks for $HOME_SRC, $XDG_SRC, $DATA_SRC
    symlinks=$({
        map_symlinks "$HOME_SRC" "$HOME";
        map_symlinks "$XDG_SRC" "$XDG_CONFIG_HOME";
        map_symlinks "$DATA_SRC" "$XDG_DATA_HOME";
    } | sort -r)

    if [ $STATUS -gt 0 ]; then
        echo "$symlinks" | status
    fi
    if [ $WRITE ]; then
        echo "$symlinks" | write_symlinks
    fi

    exec 3>&-
}

main
