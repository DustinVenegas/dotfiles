# check configured env: nvim +checkhealth

if (-not (Get-Command 'pip3' -ErrorAction SilentlyContinue)) {
	Write-Warning "Expected pip3 on Windows to install packages."
} else {
	pip3 install neovim
}

if (-not (Get-Command 'pip2' -ErrorAction SilentlyContinue)) {
	Write-Warning "Expected pip2 on Windows to install packages."
} else {
	pip2 install neovim
}

if (-not (Get-Command 'npm')) {
	Write-Warning "Expected npm on Windows."
} else {
	npm install -g markdownlint-cli
	npm install -g neovim 
}

nvim +PlugInstall +qall
