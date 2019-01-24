function Remove-TeamCityParam {
	param(
		[parameter(HelpMessage="Must be a valid TeamCity Url. Example -TCServerUrl 'http://TeamCity.yourdomain:8082'")][ValidateNotNullOrEmpty()][String[]]$TCServerUrl, 
		[parameter(HelpMessage="Valid UserName in TeamCity. Example -TCUser teamcityuser")][ValidateNotNullOrEmpty()][String[]]$TCUser,
		[parameter(HelpMessage="Password for valid UserName in TeamCity. ")][ValidateNotNullOrEmpty()][String[]]$TCSecret,
		[parameter(HelpMessage="Parameter Locator. Example -TCParamLocator 'projects/id:_Root'")][ValidateNotNullOrEmpty()][String[]]$TCParamLocator,
		[parameter(HelpMessage="Parameter Name. Example -TCParamName 'env.DefaultEnvironment'")][ValidateNotNullOrEmpty()][String[]]$TCParamName
	)
	Write-Verbose "Remove-TeamCityParam -TCServerUrl $TCServerUrl -TCUser $TCUser -TCSecret SECRET -TCParamLocator $TCParamLocator -TCParamName $TCParamName"
	try {
		$CICredential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $TCUser, (ConvertTo-SecureString -String "$TCSecret" -AsPlainText -Force)
	}
	catch {
		Write-Host "$_" 
		Throw "[ERROR] Remove-TeamCityParam: Creating CICredential for $TCUser failed"
		exit 1
	}
	$UriParameter = "$TCServerUrl/httpAuth/app/rest/latest/$TCParamLocator/parameters/$TCParamName"
	try {
		Write-Verbose "Invoke-RestMethod -Method DELETE -Uri $UriParameter"
		$TCResponse = (Invoke-RestMethod -Method DELETE -Uri $UriParameter -Credential $CICredential -Verbose)
		Write-Host "Existing State is" $TCResponse.property.name
	}
	catch {
		Write-Host "$_" 
		Write-Verbose "$UriParameter does not exist"
		exit 0
	}
}