<#

.Author
	Mariela Daventini
.SYNOPSIS
	The purpose of this module is to provide an easy way to interact with TeamCity using powershell functions.
.DESCRIPTION
	Functions for TeamCity

#>

[cmdletbinding()]
param()

Write-Verbose $PSScriptRoot

Write-Verbose 'Import everything in sub folders folder'
ForEach($Folder in @('Public')) {
	$Root = Join-Path -Path $PSScriptRoot -ChildPath $Folder
	if(Test-Path -Path $Root) {
		Write-Verbose "processing folder $Root"
		$Files = Get-ChildItem -Path $Root -Filter *.ps1 -Recurse
		# dot source each file
		$Files | Where-Object{ $_.name -NotLike '*.Tests.ps1'} | ForEach-Object {Write-Verbose $_.basename; . $PSItem.FullName}
	}
}

Export-ModuleMember -Function (Get-ChildItem -Path "$PSScriptRoot\Public\*.ps1").BaseName



