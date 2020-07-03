# VSCode

A configuration for [VSCode](https://github.com/Microsoft/vscode).

## Setup

Run the PowerShell bootstrap script.

```ps1
./bootstrap.ps1
```

## Settings Sync

[`Shan.code-settings-sync`](https://marketplace.visualstudio.com/items?itemName=Shan.code-settings-sync)
is a VSCode Extension used to synchronize settings to a gist in GitHub.

Open VSCode and install the `Shan.code-settings-sync` extension. The extension will
help setup GitHub to work with a gist upon trying to sync. Run the
`Sync: Download Settings` VSCode Palette Command to download settings.

Built-in settings sync is [coming to VSCode](https://code.visualstudio.com/docs/editor/settings-sync)
afer the feature makes it out of insiders. VSCode settings-sync is not available
as of VSCode 1.46.1, 2020/07.

## Extensions

VSCode Extensions that were useful at one time.

- `Shan.code-settings-sync` synchronizes VSCode Settings with a GitHub Gist.
- `jebbs.plantuml` renders PlantUML Diagrams for expressing development ideas.
  The plugin uses a built-in PlantUML renderer to keep data on the local
  machine by default.
- `editorconfig.editorconfig` supports formatting and linting via EditorConfig.
- `vscodevim.vim` adds vim emulation and can interface directly with neovim.
- `vscoss.vscode-ansible` supports Ansible syntax and adds various ways to run
  playbooks. Supports running on Windows via WSL or Docker.
- `dbaeumer.vscode-eslint` formats and lints JavaScript with the ESLint linter.
- `ms-vscode.powershell` adds PowerShell syntax, debugging, and linting via PSScriptAnalyzer.
- `gruntfuggly.todo-tree` aggregates `// TODO: Action` source code comments into
  the VSCode GUI via panels and panes in the sidebar.
- `timonwong.shellcheck` lint POSIX shell scripts with the shellcheck linter.
- `ms-vscode-remote.remote-wsl` adds deeper integration between VSCode on Windows
  and WSL (Windows Subsystem for Linux) so projects can be used on either operating
  system.
- `davidanson.vscode-markdownlint` lints Markdown files using markdownlint.
- `ms-vsliveshare.vsliveshare` invite other VSCode users to interactively use and
  share the same VSCode session. Think, the [NCIS Keyboard Scene](https://giphy.com/gifs/ncis-hacking-double-keyboard-yUlFNRDWVfxCM)
  with real-life productivity gains.
- `ritwickdey.liveserver` serves static HTML files in a directory locally.
- `golang.go` supports the Go Programming Language in VSCode.
- `ms-azuretools.vscode-docker` adds basic Docker support.
