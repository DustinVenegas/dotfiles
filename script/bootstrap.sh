#!/bin/sh
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

verbose=0 # Variables to be evaluated as shell arithmetic should be initialized to a default or validated beforehand.
whatif=
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

scriptroot=$(cd -- "$(dirname -- "$0")" && pwd)
dotfiles=$(cd -- "$scriptroot/.." && pwd)
retc=0
if [ $whatif ]; then m='(whatif) '; fi

# Transform templates
if [ ! -e "$dotfiles/.gitconfig_local" ]; then
	if [ ! $whatif ]; then cp "$dotfiles/git/.gitconfig_local.template" "$dotfiles/.gitconfig_local"; fi
	echo "${m}Template: $dotfiles/.gitconfig_local"
fi
if [ ! -e "$dotfiles/.config/nvim/local.dotfiles.vim" ]; then
	if [ ! $whatif ]; then cp "$dotfiles/.config/nvim/local.dotfiles.vim.template" "$dotfiles/.config/nvim/local.dotfiles.vim"; fi
	echo "${m}Template: $dotfiles/.config/nvim/local.dotfiles.vim"
fi
if [ ! -e "$dotfiles/.vimrc.local" ]; then
	if [ ! $whatif ]; then cp "$dotfiles/.vim/.vimrc.local.template" "$dotfiles/.vimrc.local"; fi
	echo "${m}Template: $dotfiles/.vimrc.local"
fi

# Item list to be symlinked.
for f in "$dotfiles"/.* "$dotfiles/.gitconfig_os" "$dotfiles"/.config/* "$dotfiles/PSScriptRoot"
do
	# Get item information.
	r=$(realpath -q --relative-to="$dotfiles" "$f") #relative
	l="$HOME/$r" # symlink file path
	lv=$(readlink -m "$l") # symlink value

	# Transform items with absolute paths.
	if [ "$f" = "$dotfiles/." ]; then f="$dotfiles"; l="$HOME/.dotfiles"; lv=$(readlink -m "$l"); fi # this repo to $HOME/.dotfiles
	if [ "$f" = "$dotfiles/.." ]; then continue; fi # skip parent directory entirely
	if [ "$f" = "$dotfiles/.git" ]; then continue; fi 
	if [ "$f" = "$dotfiles/.config" ]; then continue; fi
	if [ "$f" = "$dotfiles/.gitignore" ]; then f="$dotfiles/dot_gitignore"; fi
	if [ "$f" = "$dotfiles/.gitconfig_os" ]; then
		if [ "$(uname -s)" = "Darwin" ]; then f="$dotfiles/git/.gitconfig_os_darwin";
		else f="$dotfiles/git/.gitconfig_os_unix"; fi
	fi
	if [ "$f" = "$dotfiles/PSScriptRoot" ]; then
		l=$HOME/.local/share/powershell/Scripts
		lv=$(readlink -m "$l")
	fi

	# Transform items with wildcard paths.
	case "$f" in
		"$dotfiles/.config/"*) [ ! -e "$dotfiles/.config/" ] && mkdir "$dotfiles/.config/" ;;
	esac

	[ $verbose -gt 1 ] && printf "Evaluating: %s\n" "$f";
	[ $verbose -gt 1 ] && printf "\tRel: %s\n\tLink: %s\n\tValue: %s\n" "$r" "$l" "$lv";

	if [ -L "$l" ] && [ "$lv" = "$f" ]; then
		if [ $verbose -gt 0 ]; then echo "No Changes to symlink $l"; fi
	elif [ -L "$l" ] && [ "$lv" != "$f" ]; then
		echo "WARN: Unexpected value for symlink: $l"
		if [ $verbose -gt 0 ]; then printf "\tActual: \t%s\n\tExpected: \t%s\n" "$lv" "$f"; fi
		retc=1
	elif [ ! -e "$l" ]; then
		m=""
		if [ $whatif ]; then m='(whatif) ';
		else ln -s "$f" "$l"; fi
		echo "${m}Created symlink $l"
		if [ $verbose -gt 0 ]; then printf "\tTo: \t%s\n" "$f"; fi
	else
		echo "WARN: Existing item at symlink destination: $l"
		retc=1
	fi
done

exit $retc
