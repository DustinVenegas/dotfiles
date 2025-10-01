CONTAINER ?= mcr.microsoft.com/devcontainers/base:alpine-3.17

docker: docker/term

docker/term:
	$(info Starting terminal in $(CONTAINER) with /dotfiles mounted to $(PWD))
	docker run -it --rm -v $(PWD):/dotfiles -w /dotfiles $(CONTAINER) /bin/sh

docker/test:
	$(info Running tests in $(CONTAINER) with /dotfiles mounted to $(PWD))
	docker run -it --rm -v $(PWD):/dotfiles -w /dotfiles $(CONTAINER) make test

docker/help:
	$(info Docker Targets Help:)
	$(info - docker:      Shell in Container)
	$(info - docker/term: Shell in Container)
	$(info - docker/test: Test targets in Container)
	@false

HELP_DEPS+=docker/help