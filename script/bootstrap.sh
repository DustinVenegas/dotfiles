#!/bin/sh

whatif=
verbose=0 # Variables to be evaluated as shell arithmetic should be initialized to a default or validated beforehand.
scriptroot=$(cd -- "$(dirname -- "$0")" && pwd)
dotfiles=$(cd -- "$scriptroot/.." && pwd)
cd "$scriptroot" || exit 1
retc=0 # return code

variation=unix
if [ "$(uname -s)" = "Darwin" ]; then variation=darwin; fi

show_help() { cat << EOF
bootstrap.sh - Farms symlinks to configure a machine for this dotfiles repository.

Creates symlinks in \$HOME, \$XDC_CONFIG_HOME and other locations to configure
a machine for this dotfiles repository.

Options:
	-h|--help 	Show this help message.
	-w|--whatif 	Output what would be changed.
	-v|--verbose	Adds verbosity to output.
EOF
}

while :; do
    case $1 in
        -h|-\?|--help)   # Call a "show_help" function to display a synopsis, then exit.
            show_help
            exit
            ;;
        -w|--whatif)       # Takes an option argument, ensuring it has been specified.
			whatif=1
            ;;
        -v|--verbose)
            verbose=$((verbose + 1)) # Each -v argument adds 1 to verbosity.
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

if [ $whatif ]; then w='(whatif) '; fi
log() { printf "%s%s\n" "$w" "$1"; }
info() { [ $verbose -gt 0 ] && printf "%s\n" "$1"; }
warn() { printf "WARN: %s\n" "$1"; }

# Transform templates
copyTemplate () {
	if [ ! -f "$2" ]; then
		log "Copying Template: $2"; 
		if [ ! $whatif ]; then cp "$1" "$2"; fi
	fi
}

handleLink () {
	l=$1 # destination
	f=$2 # target
	lv=$(readlink -m "$l") # symlink value

	if [ -L "$l" ] && [ "$lv" = "$(readlink -m "$f")" ]; then
		info "No Changes to symlink $l"
	elif [ -L "$l" ] && [ "$lv" != "$f" ]; then
		warn "Unexpected value for symlink: $l"
		echo "$f $lv"
		retc=1
	elif [ ! -e "$l" ]; then
		log "Create symlink: $f $l"
		if [ ! $whatif ]; then ln -s "$f" "$l"; fi
	else
		warn "Existing item at symlink destination: $f"
		retc=1
	fi
}

# Environmental prerequisites
[ ! -d "$HOME/.config" ] && warn "Missing .config folder in \$HOME" && exit 1; # non-standard xdc path?

copyTemplate "$dotfiles/git/.gitconfig_local.template" "$dotfiles/dot_gitconfig_local"
copyTemplate "$dotfiles/.config/nvim/local.dotfiles.vim.template" "$dotfiles/.config/nvim/local.dotfiles.vim"
copyTemplate "$dotfiles/dot_vim/.vimrc.local.template" "$dotfiles/dot_vimrc.local"

# Local links
f="$dotfiles/git/.gitconfig_os_$variation"
l="$dotfiles/dot_gitconfig_os"
handleLink "$l" "$f"

# Item list to be symlinked.
for f in "$dotfiles/." "$dotfiles"/dot_* "$dotfiles"/.config/* "$dotfiles/PSScripts"
do
	# Get item information.
	r=$(realpath -s -q --relative-to="$dotfiles" "$f") # don't expand symlinks, quiet
	r=$(echo "$r" | sed "s/dot_/./") # transform dot_ to .
	l="$HOME/$r" # symlink file path

	# Transform items
	if [ "$f" = "$dotfiles/." ]; then f="$dotfiles"; l="$HOME/.dotfiles"; fi # this repo to $HOME/.dotfiles
	if [ "$f" = "$dotfiles/PSScripts" ]; then # Symlink entire folder to easily capture ad-hoc scripts.
		l="$HOME/.local/share/powershell/Scripts"
	fi

	handleLink "$l" "$f"
done

exit $retc
