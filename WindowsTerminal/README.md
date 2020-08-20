# Windows Terminal

[Windows Terminal](https://github.com/microsoft/terminal) is a terminal emulator
and multiplexier for Microsoft Windows. Windows Terminal may be useful if you
wanted to run shells like PowerShell or even Linux shells under Windows Subsystem
for Linux (WSL). `wt.exe` supports unicode fonts, copy/paste, tabs, split panes,
and more.

ConEmu is an older and more feature rich terminal emulator for Microsoft Windows.
Windows Terminal is preview software and subject to change dramatically.

## Configuration

Edit (`settings.json`)[./settings.json] to modify Windows Terminal.
You can modify and set the [Windows Terminal JSON Settings](https://github.com/microsoft/terminal/blob/master/doc/user-docs/UsingJsonSettings.md)

```ps1
# Open the Windows Terminal settings in $env:EDITOR
&$env:EDITOR %USERPROFILE%\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json
```

## Licensing

The PowerShell and PowerShell-Core icons for Windows Terminal are owned by
Microsoft and were sourced from [microsoft/terminal repository](https://github.com/microsoft/terminal).
Assets and are used with permission from Microsoft. [This way to Microsoft.com](https://www.microsoft.com/).
