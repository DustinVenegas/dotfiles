
Set-PSRepository -Name 'PSGallery' -InstallationPolicy 'Trusted'

@('posh-git', 'PSFzf', 'PSScriptAnalyzer') | Where-Object {
	$null -eq (Get-Module -Name $PSItem -ListAvailable -ErrorAction 'Continue')
} | ForEach-Object {
	Install-Module -Name $PSItem -Repository $ModuleRepository -Scope $ModuleScope
}