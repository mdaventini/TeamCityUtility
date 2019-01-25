function Get-TeamCityChanges {
	param(
		[parameter(HelpMessage="Must be a valid TeamCity Url. Example -TCServerUrl 'http://TeamCity.yourdomain:8082'")][ValidateNotNullOrEmpty()][String[]]$TCServerUrl, 
		[parameter(HelpMessage="Valid UserName in TeamCity. Example -TCUser teamcityuser")][ValidateNotNullOrEmpty()][String[]]$TCUser,
		[parameter(HelpMessage="Password for valid UserName in TeamCity. ")][ValidateNotNullOrEmpty()][String[]]$TCSecret,
		[parameter(HelpMessage="Version number. Example -TCVersion %build.vcs.number%")][ValidateNotNullOrEmpty()][String[]]$TCVersion
	)
	Write-Verbose "Get-TeamCityChanges"
	try {
		Write-Verbose "Creating CICredential for $TCUser"
		$CICredential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $TCUser, (ConvertTo-SecureString -String "$TCSecret" -AsPlainText -Force)
	}
	catch {
		Write-Host "$_" 
		Throw "[ERROR] Get-TeamCityChanges: Creating CICredential failed"
		exit 1
	}
    $UriInvoke = "$TCServerUrl/httpAuth/app/rest/latest/changes/version:$TCVersion"
	try {
		Write-Verbose "Getting Parameter using Invoke-RestMethod -Method Get -Uri $UriInvoke -Credential $CICredential -Verbose"
		$TCResponse = (Invoke-RestMethod -Method Get -Uri $UriInvoke -Credential $CICredential)
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