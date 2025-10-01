VIM?=vim
vimrc?=$(wildcard $(HOME)/.vimrc)
vimtestlog=vimtestlog
vimpluginstalllog=vimpluginstalllog

bins_required=$(VIM)
vars_required=$(HOME)
files_required=$(vimrc)
clean_files=$(vimtestlog)

include $(abspath $(addsuffix /../app.mk,$(dir $(lastword $(MAKEFILE_LIST)))))

$(vimpluginstalllog): $(addsuffix .!tmp,$(vimpluginstalllog))
	@cat $< >> $@ && rm -f $<

$(addsuffix .!tmp,$(vimpluginstalllog)): $(vimrc)
	@$(VIM) -V0$@ -c 'PlugInstall | qall' || exit 101

$(vimtestlog): $(addsuffix .!tmp,$(vimtestlog))
	@cat $< >> $@ && rm -f $<

$(addsuffix .!tmp,$(vimtestlog)): $(vimrc)
	@$(VIM) -V0$@ --cmd 'source $< | quit' || exit 101

$(addsuffix .!validate,$(vimtestlog)): $(addsuffix .!tmp,$(vimtestlog))
	@EC=100; \
	if [ -s '$<' ]; then EC=101; echo 'Unexpected content in vim log: $<'; cat '$<'; echo ''; fi \
 	elif [ -e '$(vimtestlog)' ]; then EC=0; \
 	else EC=102; echo 'error: log not found: $(vimtestlog)'; fi && \
 	exit $$EC

vim/clean:
	@rm -f $(clean_files)
	$(info $@ completed)

vim/configure: $(vimpluginstalllog)
	$(info $@ completed)

vim/health: $(addsuffix .!validate,$(vimtestlog)) $(vimtestlog)
	$(call require_binaries,$(bins_required))
	$(call require_vars,$(vars_required))
	$(call require_files,$(files_required))
	$(info $@ completed)

CLEAN_DEPS+=vim/clean
CONFIGURE_DEPS+=vim/configure
HEALTH_DEPS+=vim/health

.PHONY: vim/clean vim/configure vim/health
.DEFAULT_GOAL := vim/health
