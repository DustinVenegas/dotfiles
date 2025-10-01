python3=$(shell command -v python3 2>/dev/null)
nvim=$(shell command -v nvim 2>/dev/null)

nvim_python3_venv=$(DOTFILES_DATA_HOME)/nvim-python3-venv
nvim_health_log=$(BUILD_DIR)/nvim.log
pip3=$(nvim_python3_venv)/bin/pip3

.PHONY: nvim/health

 # Output errors (-V1) to a file. File data indicates an error.
nvim/health: $(nvim_health_log)
	-@if [ -s $< ]; then \
		echo "error: nvim log errors at: $<"; \
		cat $<; \
		echo ""; \
		rm $< ;\
		exit 1; \
	fi

$(nvim_health_log):
	@mkdir -p $(@D)
	@$(nvim) -V1$@ +qall

$(nvim_python3_venv):
	@$(python3) -m venv $@

xdg/nvim/local.dotfiles.vim: $(nvim_python3_venv)
	echo "let g:python3_host_prog='$(nvim_python3_venv)/bin/python'" >> $@

nvim/configure/neovim-node:  xdg/nvim/local.dotfiles.vim
	@if command -v 'npm' 2>&1 >/dev/null; then npm -g install neovim; else echo 'npm not found, skipping neovim install'; fi

nvim/configure/neovim-python: $(nvim_python3_venv)  xdg/nvim/local.dotfiles.vim
	@if command -v '$(pip3)' 2>&1 >/dev/null; then $(pip3) install neovim; else echo 'pip3 not found, skipping Python neovim install'; fi

nvim/configure: nvim/configure/neovim-node nvim/configure/neovim-python
	@nvim +PlugInstall +qall

HEALTH_DEPS+=nvim/health
CONFIGURE_DEPS+=nvim/configure