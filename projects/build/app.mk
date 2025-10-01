# app.mk contains shared code for apps in the apps/ folder

XDG_DATA_HOME?=$(HOME)/.local/share
DOTFILES_DATA_HOME=$(XDG_DATA_HOME)/dustinvenegas/dotfiles
BUILD_DIR=./build

SHELL=/bin/sh

TMP_EXT=.!tmp
CHECK_EXT=.!check

app_name?=$(basename $(notdir $(lastword $(wordlist 2,$(words $(MAKEFILE_LIST)),x $(MAKEFILE_LIST)))))
bins_required?=
vars_required?=

require_binary=$(shell command -v $1 2>/dev/null)
require_binaries=$(foreach bin,$1,$(if $(call require_binary,$(bin)),,$(error "$(bin) not found")))
require_var=$(if $(strip $($1)),,$(error "$1 is not set"))
require_files=$(foreach file,$1,$(if $(wildcard $(file)),,$(error "$(file)" not found. Create with 'make dotfiles/status' and 'make dotfiles/configure')))
