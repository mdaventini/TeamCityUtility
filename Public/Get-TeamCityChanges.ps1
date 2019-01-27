function Get-TeamCityChanges {
<#
	.SYNOPSIS
		Get changes in a TeamCity Instance by VCS revision. Returns a TeamCity change object.
	.DESCRIPTION
		Uses Invoke-RestMethod get method.
	.Parameter TCServerUrl
		Specifies the url of a TeamCity Instance
	.Parameter TCVersion
		VCS Version number
	.EXAMPLE
		PS C:\> Get-TeamCityChanges -TCServerUrl 'http://TeamCity.yourdomain:8082' -TCVersion %build.vcs.number%
		PS C:\> Get-TeamCityChanges -TCServerUrl 'http://TeamCity.yourdomain:8082' -TCVersion 1970
#>
	[CmdletBinding()]
	param(
		[parameter(HelpMessage="Must be a valid TeamCity Url. Example -TCServerUrl 'http://TeamCity.yourdomain:8082'")][ValidateNotNullOrEmpty()][String[]]$TCServerUrl, 
		[parameter(HelpMessage="Version number. Example -TCVersion %build.vcs.number%")][ValidateNotNullOrEmpty()][String[]]$TCVersion
	)
	Write-Verbose "Get-TeamCityChanges"
	if ( $null -eq $TCCredential ) {
		Throw "[ERROR] Get-TeamCityChanges TCCredential is empty. Use [Set-TCCredential -TCUser <username> -TCSecret <password>]"
	}
	$Verbose = ($PSBoundParameters.ContainsKey('Verbose') -and $PsBoundParameters.Get_Item('Verbose'))
    $UriInvoke = "$TCServerUrl/httpAuth/app/rest/latest/changes/version:$TCVersion"
	try {
		Write-Verbose "Invoke-RestMethod Get $UriInvoke"
		$TCResponse = (Invoke-RestMethod -Method Get -Uri $UriInvoke -Credential $TCCredential -Verbose:$Verbose)
		$TCOutput = $TCResponse.change | out-string
		Write-Verbose -Message "Change $TCOutput" 
		Return $TCResponse.change
	}
	catch {
		Write-Host "$_" 
		Throw "[ERROR] Get-TeamCityChanges: $_"
        exit 1
    }
}