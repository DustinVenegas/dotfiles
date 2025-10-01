#!/usr/bin/env bash

if [ -f "$HOME/.profile" ]; then
	# shellcheck source=/dev/null
	. "$HOME/.profile"
fi

# export PATH once
export PATH