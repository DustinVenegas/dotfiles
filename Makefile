makefile:=$(lastword $(MAKEFILE_LIST))
HELP_DEPS=help-root

include projects/build/*.mk projects/build/apps/*.mk projects/build/tests/*.mk

# Set dependencies for global app targets to run dotfiles targets first.
$(filter-out dotfiles/health,$(HEALTH_DEPS)): dotfiles/health
$(filter-out dotfiles/configure,$(CONFIGURE_DEPS)): dotfiles/configure
dotfiles/clean: $(filter-out dotfiles/clean,$(CLEAN_DEPS))

health: $(HEALTH_DEPS)
	$(info Health Checked)

configure: $(CONFIGURE_DEPS)
	$(info Configured)

clean: $(CLEAN_DEPS)
	$(info Cleaned)

test: $(TEST_DEPS)
	$(info Tests Ran)

container: container/term

container/term: docker/term

container/test: docker/test

packages: packages/configure

debug: $(BUILD_DIR)/Makefile.print
	$(info Makefile output to $<)

$(BUILD_DIR)/Makefile.print.raw: MAKE_P=-pRrqd -f $(makefile)
$(BUILD_DIR)/Makefile.print.raw: $(makefile)
	@$(MAKE) $(MAKE_P) > $@

$(BUILD_DIR)/Makefile.print: $(BUILD_DIR)/Makefile.print.raw
	@cat $< | grep -v '^#' > $@

help-root:
	$(info Make for dotfiles.sh)
	$(info Root Targets:)
	$(info - health:         All Health Targets)
	$(info - configure:      All Configure Targets)
	$(info - clean:          All Clean Targets)
	$(info - test:           All Test Targets)
	$(info - packages:       Install System Packages)
	$(info )
	$(info Sub-Targets:)
	$(info - Clean Targets:     $(CLEAN_DEPS))
	$(info - Configure Targets: $(CONFIGURE_DEPS))
	$(info - Health Targets:    $(HEALTH_DEPS))
	$(info - Help Targets:      $(HELP_DEPS))
	@false

help:
	@$(MAKE) -k -i $(HELP_DEPS)

.PHONY: term help

.DEFAULT_GOAL := help