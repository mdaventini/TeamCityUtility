function Get-TeamCityProperty {
<#
	.SYNOPSIS
		Get all properties in TeamCity by Locator and returns a TeamCity build.properties.property object.
	.DESCRIPTION
		Uses Invoke-RestMethod get method.
	.Parameter TCServerUrl
		Specifies the url of a TeamCity Instance
	.Parameter TCPropertyLocator
		Specifies the property locator
	.Parameter TCPropertyName
		Specifies the REGEX for property name
	.EXAMPLE
		PS C:\> Get-TeamCityProperty -TCServerUrl 'http://TeamCity.yourdomain:8082' -TCPropertyLocator 'projects/id:_Root' -TCPropertyName 'env.DefaultEnvironment'
#>
	[CmdletBinding()]
	param(
		[parameter(HelpMessage="Must be a valid TeamCity Url. Example -TCServerUrl 'http://TeamCity.yourdomain:8082'")][ValidateNotNullOrEmpty()][String[]]$TCServerUrl, 
		[parameter(HelpMessage="Property Locator. Example -TCPropertyLocator 'projects/id:_Root'")][ValidateNotNullOrEmpty()][String[]]$TCPropertyLocator,
		[parameter(HelpMessage="Property Name. Example -TCPropertyName 'env.DefaultEnvironment'")][ValidateNotNullOrEmpty()][String[]]$TCPropertyName
	)
	Write-Verbose "Get-TeamCityProperty"
	if ( $null -eq $TCCredential ) {
		Throw "[ERROR] Get-TeamCityProperty TCCredential is empty. Use [Set-TCCredential -TCUser <username> -TCSecret <password>]"
	}
	$Verbose = ($PSBoundParameters.ContainsKey('Verbose') -and $PsBoundParameters.Get_Item('Verbose'))
    $UriInvoke = "$TCServerUrl/httpAuth/app/rest/latest/$TCPropertyLocator"
	try {
		Write-Verbose "Invoke-RestMethod Get $UriInvoke"
		$TCResponse = (Invoke-RestMethod -Method Get -Uri $UriInvoke -Credential $TCCredential -Verbose:$Verbose).build.properties.property | Where-Object {$_.Name -match $TCPropertyName }
		$TCOutput = $TCResponse | out-string
		Write-Verbose $TCOutput
		Return $TCResponse
	}
	catch {
		Write-Host "$_" 
		Throw "[ERROR] Get-TeamCityProperty: $UriInvoke does not exist."
        exit 1
    }
}