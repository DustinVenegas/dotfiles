PWSH=$(shell command -v pwsh 2> /dev/null)

pwsh/configure:
	@pwsh -NoProfile -Command "Set-PSRepository -Name 'PSGallery' -InstallationPolicy 'Trusted'; \
	@('posh-git', 'PSFzf', 'PSScriptAnalyzer') | \
	Where-Object { \$$null -eq (Get-Module -Name \$$PSItem -ListAvailable -ErrorAction 'Continue') } | \
	ForEach-Object { WRite-Host \$$PSitem; Install-Module -Name \$$PSItem -Repository PSGallery -Scope CurrentUser}"

pwsh/health:
	-@env -i $(PWSH) -NoProfile -Command '$(call pwsh_health,$(HOME)/.config/powershell/profile.ps1)' > /dev/null

define pwsh_health
try { \
	. $(1); \
    if ($$LASTEXITCODE -ne 0) { exit $$LASTEXITCODE } \
} catch { Write-Error "Error: $$_"; exit 101 }
endef

HEALTH_DEPS+=pwsh/health
CONFIGURE_DEPS+=pwsh/configure