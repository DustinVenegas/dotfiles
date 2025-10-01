GIT=$(shell command -v git 2> /dev/null)

bins_required=$(GIT)

include $(abspath $(addsuffix /../app.mk,$(dir $(lastword $(MAKEFILE_LIST)))))

.PHONY: git/health

git/health:
	$(call require_binaries,$(bins_required))
	-@($(GIT) version 1>/dev/null || (echo "Errored git binary: $(GIT)"; exit 101)) && \
	($(GIT) config --get user.name 1>/dev/null || (echo "Missing git username!"; exit 102)) && \
	($(GIT) config --get user.email 1>/dev/null || (echo "Missing git email!"; exit 103))

HEALTH_DEPS+=git/health