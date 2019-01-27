function Get-TeamCityBuildsByRevision {
<#
	.SYNOPSIS
		Get builds on a TeamCity Instance by revision. Returns a TeamCity build object.
	.DESCRIPTION
		Uses Invoke-RestMethod get
	.Parameter TCServerUrl
		Specifies the url of a TeamCity Instance
	.Parameter TCVersion
		Specifies the revision #
	.EXAMPLE
		PS C:\> Get-TeamCityBuildsByRevision -TCServerUrl %teamcity.serverUrl% -TCVersion %build.vcs.number%
		PS C:\> Get-TeamCityBuildsByRevision -TCServerUrl 'http://TeamCity.yourdomain:8082' -TCVersion 1970
#>
	[CmdletBinding()]
	param(
		[parameter(HelpMessage="Must be a valid TeamCity Url. Example -TCServerUrl 'http://TeamCity.yourdomain:8082'")][ValidateNotNullOrEmpty()][String[]]$TCServerUrl, 
		[parameter(HelpMessage="Version number. Example -TCVersion %build.vcs.number%")][ValidateNotNullOrEmpty()][String[]]$TCVersion
	)
	Write-Verbose "Get-TeamCityBuildsByRevision -TCVersion $TCVersion"
	if ( $null -eq $TCCredential ) {
		Throw "[ERROR] Get-TeamCityBuildsByRevision TCCredential is empty. Use [Set-TCCredential -TCUser <username> -TCSecret <password>]"
	}
	$Verbose = ($PSBoundParameters.ContainsKey('Verbose') -and $PsBoundParameters.Get_Item('Verbose'))
	$UriInvoke = "$TCServerUrl/httpAuth/app/rest/latest/builds?locator=revision(version:$TCVersion)"
	try {
		Write-Verbose "Invoke-RestMethod Get $UriInvoke"
		$TCResponse = (Invoke-RestMethod -Method Get -Uri $UriInvoke -Credential $TCCredential -Verbose:$Verbose)
		$TCOutput = $TCResponse.builds.build | out-string
		Write-Verbose -Message "Response $TCOutput" 
		Return $TCResponse.builds.build
	}
	catch {
		Write-Host "$_" 
		Throw "[ERROR] Get-TeamCityBuildsByRevision: $_"
		exit 1
	}
}