function Get-TeamCityBuildsByLocator {
<#
	.SYNOPSIS
		Get builds on a TeamCity Instance by revision. Returns TeamCity builds.build model.
	.DESCRIPTION
		Uses Invoke-RestMethod get
	.Parameter TCServerUrl
		Specifies the url of a TeamCity Instance
	.Parameter TCBuildLocator
		Specifies the revision #
	.EXAMPLE
		PS C:\> Get-TeamCityBuildsByLocator -TCServerUrl %teamcity.serverUrl% -TCBuildLocator buildType:(template(id:MyTemplate)),revision(version:1970),state:running
		Will return all builds running with template = MyTemplate with VCS version 1970
	.EXAMPLE
		PS C:\> Get-TeamCityBuildsByLocator -TCServerUrl 'http://TeamCity.yourdomain:8082' -TCBuildLocator buildType:revision(version:1970)
		Will return all builds with VCS version 1970
#>
	[CmdletBinding()]
	param(
		[parameter(HelpMessage="Must be a valid TeamCity Url. Use Get-Help Get-TeamCityBuildsByLocator -Examples to see examples")][ValidateNotNullOrEmpty()][String[]]$TCServerUrl, 
		[parameter(HelpMessage="Version number. Use Get-Help Get-TeamCityBuildsByLocator -Examples to see examples")][ValidateNotNullOrEmpty()][String[]]$TCBuildLocator
	)
	Write-Verbose "Get-TeamCityBuildsByLocator -TCBuildLocator $TCBuildLocator"
	if ( $null -eq $TCCredential ) {
		Throw "[ERROR] Get-TeamCityBuildsByLocator TCCredential is empty. Use [Set-TCCredential -TCUser <username> -TCSecret <password>]"
	}
	$Verbose = ($PSBoundParameters.ContainsKey('Verbose') -and $PsBoundParameters.Get_Item('Verbose'))
	$UriInvoke = "$TCServerUrl/httpAuth/app/rest/latest/builds/?locator=$TCBuildLocator"
	try {
		Write-Verbose "Invoke-RestMethod Get $UriInvoke"
		$TCResponse = (Invoke-RestMethod -Method Get -Uri $UriInvoke -Credential $TCCredential -Verbose:$Verbose)
		$TCOutput = $TCResponse.builds.build | out-string
		Write-Verbose -Message "Response $TCOutput" 
		Return $TCResponse.builds.build
	}
	catch {
		Write-Host "$_" 
		Throw "[ERROR] Get-TeamCityBuildsByLocator: $_"
		exit 1
	}
}