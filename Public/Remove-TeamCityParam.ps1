function Remove-TeamCityParam {
<#
	.SYNOPSIS
		Remove a TeamCity Parameter on a TeamCity Instance by Locator.
	.DESCRIPTION
		Uses Invoke-RestMethod DELETE method.
	.Parameter TCServerUrl
		Specifies the url of a TeamCity Instance
	.Parameter TCParamLocator
		Specifies the parameter locator
	.Parameter TCParamName
		Specifies the parameter name
	.EXAMPLE
		PS C:\> Remove-TeamCityParam -TCServerUrl 'http://TeamCity.yourdomain:8082' -TCParamLocator 'projects/id:_Root' -TCParamName 'env.DefaultEnvironment'
#>
	param(
		[parameter(HelpMessage="Must be a valid TeamCity Url. Example -TCServerUrl 'http://TeamCity.yourdomain:8082'")][ValidateNotNullOrEmpty()][String[]]$TCServerUrl, 
		[parameter(HelpMessage="Parameter Locator. Example -TCParamLocator 'projects/id:_Root'")][ValidateNotNullOrEmpty()][String[]]$TCParamLocator,
		[parameter(HelpMessage="Parameter Name. Example -TCParamName 'env.DefaultEnvironment'")][ValidateNotNullOrEmpty()][String[]]$TCParamName
	)
	Write-Verbose "Remove-TeamCityParam -TCServerUrl $TCServerUrl -TCParamLocator $TCParamLocator -TCParamName $TCParamName"
	if ( $null -eq $TCCredential ) {
		Throw "[ERROR] Remove-TeamCityParam TCCredential is empty. Use [Set-TCCredential -TCUser <username> -TCSecret <password>]"
	}
	$Verbose = ($PSBoundParameters.ContainsKey('Verbose') -and $PsBoundParameters.Get_Item('Verbose'))
	$UriInvoke = "$TCServerUrl/httpAuth/app/rest/latest/$TCParamLocator/parameters/$TCParamName"
	try {
		Write-Verbose "Invoke-RestMethod DELETE $UriInvoke"
		$TCResponse = (Invoke-RestMethod -Method DELETE -Uri $UriInvoke -Credential $TCCredential -Verbose:$Verbose)
		Write-Host "Existing State is" $TCResponse.property.name
	}
	catch {
		Write-Host "$_" 
		Write-Verbose "$UriInvoke does not exist"
		exit 0
	}
}