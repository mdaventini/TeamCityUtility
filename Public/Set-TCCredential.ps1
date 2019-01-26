function Set-TCCredential {
<#
	.SYNOPSIS
		Set TCCredential variable -Scope Global
	.DESCRIPTION
		Uses New-Object -TypeName "System.Management.Automation.PSCredential" to create a new Global variable.
	.Parameter TCUser
		Specifies the username for the PSCredential
	.Parameter TCSecret
		Specifies the password for the PSCredential
	.EXAMPLE
		PS C:\> Set-TCCredential -TCUser <username> -TCSecret <password>
#>
	[CmdletBinding()]
	param(
		[parameter(HelpMessage="Valid UserName in TeamCity. Example -TCUser teamcityuser")][ValidateNotNullOrEmpty()][String[]]$TCUser,
		[parameter(HelpMessage="Password for valid UserName in TeamCity. ")][ValidateNotNullOrEmpty()][String[]]$TCSecret
	)
	Write-Verbose "Set-TCCredential -TCUser $TCUser -TCSecret SECRET"
	try {
		$NewCredential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $TCUser, (ConvertTo-SecureString -String "$TCSecret" -AsPlainText -Force) -Verbose
		Set-Variable -Name TCCredential -Value $NewCredential -Scope Global
	}
	catch {
		Write-Host "$_" 
		Throw "[ERROR] Set-TCCredential: Creating Credential for $TCUser failed"
		exit 1
	}
}