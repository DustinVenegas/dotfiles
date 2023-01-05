#!/bin/sh

scriptroot=$(cd -- "$(dirname -- "$0")" && pwd)

# Move originals into home_backup
[ ! -d home_backup ] && mkdir home_backup
bk () { [ ! -L "$HOME/$1" ] && [ -f "$HOME/$1" ] && mv "$HOME/$1" home_backup/; }
bk '.bashrc'
bk '.gitconfig'
bk '.zshrc'

# dotfiles packages
sudo apk add neovim ripgrep fzf

installPwsh () {
	####################
	## PowerShell Core
	# install the requirements
	sudo apk add --no-cache \
		ca-certificates \
		less \
		ncurses-terminfo-base \
		krb5-libs \
		libgcc \
		libintl \
		libssl1.1 \
		libstdc++ \
		tzdata \
		userspace-rcu \
		zlib \
		icu-libs \
		curl

	sudo apk -X https://dl-cdn.alpinelinux.org/alpine/edge/main add --no-cache \
		lttng-ust

	# Download the powershell '.tar.gz' archive
	curl -L https://github.com/PowerShell/PowerShell/releases/download/v7.3.0/powershell-7.3.0-linux-alpine-x64.tar.gz -o /tmp/powershell.tar.gz

	# Create the target folder where powershell will be placed
	sudo mkdir -p /opt/microsoft/powershell/7

	# Expand powershell to the target folder
	sudo tar zxf /tmp/powershell.tar.gz -C /opt/microsoft/powershell/7

	# Set execute permissions
	sudo chmod +x /opt/microsoft/powershell/7/pwsh

	# Create the symbolic link that points to pwsh
	sudo ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh
}

if ! command -v pwsh 1>/dev/null; then installPwsh; fi
if ! command -v oh-my-posh 1>/dev/null; then
	sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
	sudo chmod +x /usr/local/bin/oh-my-posh
fi

# Farm symlinks with the generic bootstrapper.
$scriptroot/bootstrap.sh