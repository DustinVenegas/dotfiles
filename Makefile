help:
	echo "Build for dotfiles. The following make commands are available:"
	echo ""
	echo "make lint"
	echo "Runs linters against the project."

lint:
	@markdownlint **/*.md

.PHONY: lint help
.DEFAULT_GOAL := help
