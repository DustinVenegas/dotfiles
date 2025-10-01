ZSH=$(shell command -v zsh 2> /dev/null)
zshsourcelog=zshsourcelog

bins_required=$(ZSH)

include $(abspath $(addsuffix /../app.mk,$(dir $(lastword $(MAKEFILE_LIST)))))

$(addsuffix .!tmp,$(zshsourcelog)): $(HOME)/.zshrc
	@env -i '$(ZSH)' -e -c --no-rcs 'set -eu; source "$<"; exit $$? >$@' || exit 101

# zsh/clean:
# 	$(info $@ completed)

# zsh/configure:
# 	$(info $@ completed)

zsh/health: $(addsuffix .!tmp,$(zshsourcelog))
	$(call require_binaries,$(bins_required))
	$(info $@ completed)

HEALTH_DEPS+=zsh/health

.PHONY: zsh/health
.DEFAULT_GOAL := zsh/health