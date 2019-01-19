function Get-TeamCityParam {
	param(
		[parameter(HelpMessage="Must be a valid TeamCity Url. Example -TCServerUrl 'http://TeamCity.yourdomain:8082'")][ValidateNotNullOrEmpty()][String[]]$TCServerUrl, 
		[parameter(HelpMessage="Valid UserName in TeamCity. Example -TCUser teamcityuser")][ValidateNotNullOrEmpty()][String[]]$TCUser,
		[parameter(HelpMessage="Password for valid UserName in TeamCity. ")][ValidateNotNullOrEmpty()][String[]]$TCSecret,
		[parameter(HelpMessage="Parameter Locator. Example -TCParamLocator 'projects/id:_Root'")][ValidateNotNullOrEmpty()][String[]]$TCParamLocator,
		[parameter(HelpMessage="Parameter Name. Example -TCParamName 'env.DefaultEnvironment'")][ValidateNotNullOrEmpty()][String[]]$TCParamName
	)
	Write-Verbose "Get-TeamCityParam"
	try {
		Write-Verbose "Creating CICredential for $TCUser"
		$CICredential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $TCUser, (ConvertTo-SecureString -String "$TCSecret" -AsPlainText -Force)
	}
	catch {
		Write-Host "$_" 
		Throw "[ERROR] Get-TeamCityParam: Creating CICredential failed"
		exit 1
	}
    $UriParameter = "$TCServerUrl/httpAuth/app/rest/latest/$TCParamLocator/parameters/$TCParamName"
	try {
		Write-Verbose "Getting Parameter using Invoke-RestMethod -Method Get -Uri $UriParameter -Credential $CICredential -Verbose"
		$TCResponse = (Invoke-RestMethod -Method Get -Uri $UriParameter -Credential $CICredential)
		Write-Verbose $TCResponse.property.value
		Return $TCResponse.property.value
	}
	catch {
		Write-Host "$_" 
		Throw "[ERROR] Get-TeamCityParam: $UriParameter does not exist."
        exit 1
    }
}