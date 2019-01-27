function Get-TeamCityParam {
<#
	.SYNOPSIS
		Get a TeamCity Parameter value on a TeamCity Instance by Locator.
	.DESCRIPTION
		Uses Invoke-RestMethod get method.
	.Parameter TCServerUrl
		Specifies the url of a TeamCity Instance
	.Parameter TCParamLocator
		Specifies the parameter locator
	.Parameter TCParamName
		Specifies the parameter name
	.EXAMPLE
		PS C:\> Get-TeamCityParam -TCServerUrl 'http://TeamCity.yourdomain:8082' -TCParamLocator 'projects/id:_Root' -TCParamName 'env.DefaultEnvironment'
#>
	[CmdletBinding()]
	param(
		[parameter(HelpMessage="Must be a valid TeamCity Url. Example -TCServerUrl 'http://TeamCity.yourdomain:8082'")][ValidateNotNullOrEmpty()][String[]]$TCServerUrl, 
		[parameter(HelpMessage="Parameter Locator. Example -TCParamLocator 'projects/id:_Root'")][ValidateNotNullOrEmpty()][String[]]$TCParamLocator,
		[parameter(HelpMessage="Parameter Name. Example -TCParamName 'env.DefaultEnvironment'")][ValidateNotNullOrEmpty()][String[]]$TCParamName
	)
	Write-Verbose "Get-TeamCityParam"
	if ( $null -eq $TCCredential ) {
		Throw "[ERROR] Get-TeamCityParam TCCredential is empty. Use [Set-TCCredential -TCUser <username> -TCSecret <password>]"
	}
	$Verbose = ($PSBoundParameters.ContainsKey('Verbose') -and $PsBoundParameters.Get_Item('Verbose'))
	$UriInvoke = "$TCServerUrl/httpAuth/app/rest/latest/$TCParamLocator/parameters/$TCParamName"
	try {
		Write-Verbose "Invoke-RestMethod Get $UriInvoke"
		$TCResponse = (Invoke-RestMethod -Method Get -Uri $UriInvoke -Credential $TCCredential -Verbose:$Verbose)
		Write-Verbose $TCResponse.property.value
		Return $TCResponse.property.value
	}
	catch {
		Write-Host "$_" 
		Throw "[ERROR] Get-TeamCityParam: $UriInvoke does not exist."
        exit 1
    }
}