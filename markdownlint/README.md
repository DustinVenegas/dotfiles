# Markdownlint

[Markdownlint](https://github.com/markdownlint/markdownlint) is a CLI tool used to lint Markdown files.

This dotfiles repository contains configuration settings for markdownlint and uses markdownlint-cli.

## Installation

Requires node.js.

macOS, Linux

```sh
./bash/bootstrap.sh && npm install
```

## Configuration

Use `$HOME/.gitconfig_local` for any machine-specific configuration.

Configuration files are symlinked from the dotfiles repository to `$HOME` paths.

- `$HOME/.markdownlintrc` points to `markdownlint.json`

[markdownlint configuration](https://github.com/markdownlint/markdownlint/blob/master/docs/configuration.md)
