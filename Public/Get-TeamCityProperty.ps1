function Get-TeamCityProperty {
	param(
		[parameter(HelpMessage="Must be a valid TeamCity Url. Example -TCServerUrl 'http://TeamCity.yourdomain:8082'")][ValidateNotNullOrEmpty()][String[]]$TCServerUrl, 
		[parameter(HelpMessage="Valid UserName in TeamCity. Example -TCUser teamcityuser")][ValidateNotNullOrEmpty()][String[]]$TCUser,
		[parameter(HelpMessage="Password for valid UserName in TeamCity. ")][ValidateNotNullOrEmpty()][String[]]$TCSecret,
		[parameter(HelpMessage="Property Locator. Example -TCPropertyLocator 'projects/id:_Root'")][ValidateNotNullOrEmpty()][String[]]$TCPropertyLocator,
		[parameter(HelpMessage="Property Name. Example -TCPropertyName 'env.DefaultEnvironment'")][ValidateNotNullOrEmpty()][String[]]$TCPropertyName,
	)
	Write-Verbose "Get-TeamCityProperty"
	try {
		Write-Verbose "Creating CICredential for $TCUser"
		$CICredential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $TCUser, (ConvertTo-SecureString -String "$TCSecret" -AsPlainText -Force)
	}
	catch {
		Write-Host "$_" 
		Throw "[ERROR] Get-TeamCityProperty: Creating CICredential failed"
		exit 1
	}
    $UriProperty = "$TCServerUrl/httpAuth/app/rest/latest/$TCPropertyLocator"
	try {
		Write-Verbose "Getting Property using Invoke-RestMethod -Method Get -Uri $UriProperty -Credential $CICredential -Verbose"
		$TCResponse = (Invoke-RestMethod -Method Get -Uri $UriProperty -Credential $CICredential)
$TCResponse
	}
	catch {
		Write-Host "$_" 
		Throw "[ERROR] Get-TeamCityProperty: $UriProperty does not exist."
        exit 1
    }
}