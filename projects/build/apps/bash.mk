APP_NAME:=$(notdir $(basename $(lastword $(MAKEFILE_LIST))))
HEALTH_TARGET=$(APP_NAME)/health
BASH=$(shell command -v bash 2> /dev/null)
ENV=$(shell command -v env 2> /dev/null)
BASHRC=$(HOME)/.bashrc
BASH_CLEAN=$(ENV) -i $(BASH) -e -c 'set -eu; HOME=$(HOME) $(1); exit $$?'

include $(abspath $(addsuffix /../app.mk,$(dir $(lastword $(MAKEFILE_LIST)))))

$(HEALTH_TARGET):
	$(call require_binaries,$(BASH) $(ENV))
	$(call require_files,$(BASHRC))
	@env -i $(BASH) -e -c 'set -eu; HOME=$(HOME) source "$(HOME)/.bashrc"; exit $$?'

health: $(HEALTH_DEPS)

.PHONY: $(HEALTH_TARGET)

HEALTH_DEPS+=$(HEALTH_TARGET)