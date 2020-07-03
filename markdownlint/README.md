# Markdownlint

[Markdownlint](https://github.com/markdownlint/markdownlint) is a CLI tool used to lint Markdown files.

This dotfiles repository contains configuration settings for markdownlint and uses markdownlint-cli.

## Installation

Requires node.js.

macOS, Linux

```sh
# Run bootstrapper to install dependencies and perform basic configuration.
./bootstrap.ps1

# Run `markdownlint` from the markdownlint-cli NPM package.
npx --package markdownlint-cli markdownlint **/*.md
```

## Configuration

Configuration files are symlinked from the dotfiles repository to `$HOME` paths.

- `$HOME/.markdownlintrc` points to `markdownlint.json`

[markdownlint configuration](https://github.com/markdownlint/markdownlint/blob/master/docs/configuration.md)
