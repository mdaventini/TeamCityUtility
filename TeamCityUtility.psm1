<#

.Author
	Mariela Daventini
.SYNOPSIS
	The purpose of this module is to provide an easy way to interact with TeamCity using powershell functions.
.DESCRIPTION
	Functions for TeamCity

#>

$TCFunctions  = @(Get-ChildItem -Recurse -Path $PSScriptRoot\*.ps1 | Where-Object { $_ -notmatch '\.Tests.ps1' })

ForEach ($ThisFunction in @($TCFunctions)) {
    try {
        . $ThisFunction.fullname
    }
    catch {
        Write-Error -Message "Failed to import function $($ThisFunction.fullname): $_"
    }
}

Export-ModuleMember -Function $TCFunctions.Basename