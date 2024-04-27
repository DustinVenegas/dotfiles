XDG_CONFIG_HOME ?= $(HOME)/.config
XDG_DATA_HOME ?= $(HOME)/.local/share
DIST_DIR ?= $(or $(dist),dist)
BUILD_DIR ?= $(or $(build),build)
CONTAINER ?= mcr.microsoft.com/devcontainers/base:alpine-3.17
HOME ?= $(error HOME variable is not set. Please set the HOME variable.)

SRCS=xdg local home
DESTS=$(XDG_CONFIG_HOME) $(XDG_DATA_HOME) $(HOME)
INTERNAL_LINKS := xdg/git/.gitconfig_os

# Quick validate SRCS and DESTS since index are correlated.
$(foreach src,$(SRCS),$(if $(wildcard $(src)/*),,$(error SRC '$(src)' must exist with files)))
$(foreach dest,$(DESTS),$(if $(wildcard $(dest)),,$(error DEST '$(dest)' does not exist)))
$(if $(filter-out $(words $(SRCS)),$(words $(DESTS))),$(error SRCS and DESTS must have the same number of words))

all_items = $(filter-out %. %..,$(wildcard $(addsuffix /.*,$1)) $(wildcard $(addsuffix /*,$1)))
SEQ = $(shell seq 1 $(words $1))
ALL_INSTALL_FILES = $(foreach i,$(call SEQ,$(SRCS)),$(addprefix $(word $(i),$(DESTS))/,$(notdir $(call all_items,$(word $(i),$(SRCS))))))

DIST_SDIRS = $(addprefix dist/,$(addsuffix /.,$(SRCS)))
DIST_FILES = $(addprefix $(DIST_DIR)/,$(foreach src,$(SRCS),$(call all_items,$(src))))

GITCONFIGOS = xdg/git/.gitconfig_os_$(if $(filter Darwin,$(shell uname -s)),darwin,unix)
DIST_GITHASH = $(DIST_DIR)/githash

.PHONY: clean clean/internal dist distclean internal term

clean:
	@rm -rf $(BUILD_DIR) 

clean/internal:
	@rm -f $(INTERNAL_LINKS)

dist: dist/update_time
	$(info Completed dist)
	@true

distclean:
	@rm -rf $(DIST_DIR)

internal: build/internal
	@true

term:
	$(info Starting terminal in $(CONTAINER) with /dotfiles mounted to $(PWD))
	docker run -it --rm -v $(PWD):/dotfiles -w /dotfiles $(CONTAINER) /bin/sh

# Differentiate dir creation from other targets by appending a `/.`.
$(DIST_DIR)/. $(BUILD_DIR)/. $(DIST_SDIRS):
	@mkdir -p $@

$(DIST_FILES): | $(DIST_SDIRS)
$(DIST_GITHASH): | $(DIST_SDIRS)

dist/update_time: $(DIST_FILES) | $(DIST_DIR)/. $(DIST_GITHASH)
	$(info $@ DIST_FILES=$?)
	@date -u > $@

build/internal: $(INTERNAL_LINKS) | $(BUILD_DIR)/.
	$(info Created Internal Links: $?)
	@touch $@

$(DIST_DIR)/%:
	@$(info Dist $@ from $*)
	@ln -s -f $(CURDIR)/$* $@

dist/githash:
	@echo $(shell git rev-parse HEAD) > $@

xdg/git/.gitconfig_os: $(GITCONFIGOS)
	$(info Linking $(CURDIR)/$< to $@)
	@ln -s -f $(CURDIR)/$< $@
