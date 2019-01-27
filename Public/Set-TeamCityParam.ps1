function Set-TeamCityParam {
<#
	.SYNOPSIS
		Set a TeamCity Parameter on a TeamCity Instance by Locator.
	.DESCRIPTION
		Uses Invoke-RestMethod get and put methods.
		If the parameter does not exists, creates it with the given rawValue and value.
		If the parameter exists, updates rawValue and value (only if is <> "keep").
	.Parameter TCServerUrl
		Specifies the url of a TeamCity Instance
	.Parameter TCParamLocator
		Specifies the parameter locator
	.Parameter TCParamName
		Specifies the parameter name
	.Parameter TCParamRaw
		Specifies the parameter rawValue
	.Parameter TCParamValue
		Specifies the parameter value
	.EXAMPLE
		PS C:\> Set-TeamCityParam -TCServerUrl 'http://TeamCity.yourdomain:8082' -TCParamLocator 'projects/id:_Root' -TCParamName 'env.DefaultEnvironment' -TCParamRaw "select display='hidden' description='Default environment' data_1='Dev' data_2='Test' data_3='Staging' data_4='Production'" -TCParamValue Dev
#>
	[CmdletBinding()]
	param(
		[parameter(HelpMessage="Must be a valid TeamCity Url. Example -TCServerUrl 'http://TeamCity.yourdomain:8082'")][ValidateNotNullOrEmpty()][String[]]$TCServerUrl, 
		[parameter(HelpMessage="Parameter Locator. Example -TCParamLocator 'projects/id:_Root'")][ValidateNotNullOrEmpty()][String[]]$TCParamLocator,
		[parameter(HelpMessage="Parameter Name. Example -TCParamName 'env.DefaultEnvironment'")][ValidateNotNullOrEmpty()][String[]]$TCParamName,
		[parameter(HelpMessage="Parameter rawValue. Example -TCParamRaw select display='hidden' description='Default environment' data_1='Dev' data_2='Test' data_3='Staging' data_4='Production'")][ValidateNotNullOrEmpty()][String[]]$TCParamRaw,
		[parameter(HelpMessage="Parameter Value. Example -TCParamValue Dev")][String[]]$TCParamValue
	)
	Write-Verbose "Set-TeamCityParam -TCServerUrl $TCServerUrl -TCParamLocator $TCParamLocator -TCParamName $TCParamName -TCParamRaw $TCParamRaw -TCParamValue $TCParamValue"
	if ( $null -eq $TCCredential ) {
		Throw "[ERROR] Set-TeamCityParam TCCredential is empty. Use [Set-TCCredential -TCUser <username> -TCSecret <password>]"
	}
	$ESValue = ""
	$ESRawValue = ""
	$Verbose = ($PSBoundParameters.ContainsKey('Verbose') -and $PsBoundParameters.Get_Item('Verbose'))
	$UriInvoke = "$TCServerUrl/httpAuth/app/rest/latest/$TCParamLocator/parameters/$TCParamName"
	try {
		Write-Verbose "Invoke-RestMethod Get $UriInvoke"
		$TCResponse = (Invoke-RestMethod -Method Get -Uri $UriInvoke -Credential $TCCredential -Verbose:$Verbose)
		$ESValue = $TCResponse.property.value
		$ESRawValue = $TCResponse.property.type.rawValue
		Write-Host "Existing State is" $TCResponse.property.name $ESValue $ESRawValue
	}
	catch {
		Write-Host "$_" 
		Write-Verbose "$UriInvoke does not exist ... creating"
		$JData = (@{value = ""}) | ConvertTo-Json
		$TCResponse = ( Invoke-RestMethod -Method PUT -Uri $UriInvoke -ContentType "application/json" -Credential $TCCredential -Body $JData -Verbose:$Verbose )
		$ESValue = $TCResponse.property.value
	}
	try {
		#Keep existing data
		if ( "$TCParamValue" -ne "keep" ) {
			if ( "$ESValue" -ne "$TCParamValue" ) {
				Write-Verbose "Invoke-RestMethod PUT $UriInvoke/value -Body $TCParamValue"
				$TCResponse = ( Invoke-RestMethod -Method PUT -Uri $UriInvoke/value -Credential $TCCredential -Body $TCParamValue -Verbose:$Verbose )
			} else {
				Write-Verbose "$UriInvoke/value is up to date"
			}
		}
		#Keep existing data
		if ( "$TCParamRaw" -ne "keep" ) {
			if ( "$ESRawValue" -ne "$TCParamRaw" ) {
				Write-Verbose "Invoke-RestMethod PUT $UriInvoke/type/rawValue -Body $TCParamRaw"
				$TCResponse = ( Invoke-RestMethod -Method PUT -Uri $UriInvoke/type/rawValue -Credential $TCCredential -Body $TCParamRaw -Verbose:$Verbose ) 
			} else {
				Write-Verbose "$UriInvoke/type/rawValue is up to date"
			}
		}
	}
	catch {
		Write-Host "$_" 
		Throw "[ERROR] Set-TeamCityParam: $UriInvoke was not updated"
		exit 1
	}
}