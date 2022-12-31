# skip on ALL
	script/*
	LICENSE.md
	README.md

# only on Windows
    _vimrc as .vimrc
	AppData
	.config as $env:LOCALAPPDATA

# skip on Windows
	.bashrc
	.bash_profile
	.bashrc.local
	.zshrc
	.zshrc.local
    .vimrc

# only on macOS

	.config/kitty/kitty.conf

# include on all
	.markdownlintrc
	.ripgreprc
        .gitattributes
        .gitconfig
        .gitignore
        .gitconfig_local
        .gitconfig_os
        Copy-Item -Path gitconfig_local.template -Destination gitconfig_local | Out-Null

    .vim/
    .vimrc or _rimrc as '.vimrc.entrypoint'
	.config/powershell OR 'Documents/PowerShell'

# ENVVARS on all
    Set-UserEnvVar -Name RIPGREP_CONFIG_PATH -Value $ripgreprcHomePath
    Set-UserEnvVar -Name EDITOR -Value 'nvim-qt'

# Scripts on all
        # Blindly update plugins in vim.
        vim +PlugInstall +qall


    @{
        $(Join-Path -Path $HOME -ChildPath '.gitattributes')   = $(Join-Path -Path $PSScriptRoot -ChildPath 'gitattributes')
        $(Join-Path -Path $HOME -ChildPath '.gitconfig')       = $(Join-Path -Path $PSScriptRoot -ChildPath 'gitconfig')
        $(Join-Path -Path $HOME -ChildPath '.gitignore')       = $(Join-Path -Path $PSScriptRoot -ChildPath 'gitignore')
        $(Join-Path -Path $HOME -ChildPath '.gitconfig_local') = $(Join-Path -Path $PSScriptRoot -ChildPath 'gitconfig_local')
        $(Join-Path -Path $HOME -ChildPath '.gitconfig_os')    = $(Join-Path -Path $PSScriptRoot -ChildPath "gitconfig_os_$SimplifiedOSPlatform")
    }.GetEnumerator() | ForEach-Object {
        New-SymbolicLink -Path $PSItem.Key -Value $PSItem.Value
    }