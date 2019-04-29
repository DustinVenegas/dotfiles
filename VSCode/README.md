# VSCode

Dotfiles for [VSCode](https://github.com/Microsoft/vscode).

## Setup

- Windows, in an elevated (Administrator) PowerShell Console: `./VSCode/bootstrap.ps1`
- MacOS, in your terminal: `./VSCode/bootstrap.sh`

### Plugins

Plugins are poorly managed by lists in the `bootstrap.*` scripts.

A list of optional extensions that might be recommended depending on the
situation are below:

- [`jebbs.plantuml`](https://marketplace.visualstudio.com/items?itemName=jebbs.plantuml),
  PlantUML Diagram rendering
    - Install PlantUML. `choco install plantuml`, `apt-get install plantuml`,
      `brew install plantuml`
- `ms-vsts.team`, Visual Studio Team Services integration
- `vscoss.vscode-ansible`, Ansible Integration
- `ms-vscode.csharp`, official C# Extension
- `peterjausovec.vscode-docker`
- `editorconfig.editorconfig`, auto-formatting and checking for EditorConfig
- `dbaeumer.vscode-eslint`
- `haaaad.ansible`
- `fknop.vscode-npm`
- `ms-vscode.powershell`, PowerShell Syntax, Debugging
- `vscodevim.vim`, vim, neovmim, and nvim emulation and integration via pipes.
- `robertohuertasm.vscode-icons`, Icons in the VSCode Explorer

## Configuration

Configuration files are Symlinked from the dotfiles repository to their expected
paths.
