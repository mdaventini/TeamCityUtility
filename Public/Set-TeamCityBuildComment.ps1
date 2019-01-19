function Set-TeamCityBuildComment {
	param(
		[parameter(HelpMessage="Must be a valid TeamCity Url. Example -TCServerUrl 'http://TeamCity.yourdomain:8082'")][ValidateNotNullOrEmpty()][String[]]$TCServerUrl, 
		[parameter(HelpMessage="Valid UserName in TeamCity. Example -TCUser teamcityuser")][ValidateNotNullOrEmpty()][String[]]$TCUser,
		[parameter(HelpMessage="Password for valid UserName in TeamCity. ")][ValidateNotNullOrEmpty()][String[]]$TCSecret,
		[parameter(HelpMessage="Build Locator. Example -TCBuildLocator 'builds/id:1970'")][ValidateNotNullOrEmpty()][String[]]$TCBuildLocator,
		[parameter(HelpMessage="Comment. Example -Comment 'Triggered by ...'")][ValidateNotNullOrEmpty()][String[]]$Comment
	)
	Write-Verbose "Set-TeamCityBuildComment"
	try {
		Write-Verbose "Creating CICredential for $TCUser"
		$CICredential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $TCUser, (ConvertTo-SecureString -String "$TCSecret" -AsPlainText -Force)
	}
	catch {
		Write-Host "$_" 
		Throw "[ERROR] Set-TeamCityBuildComment: Creating CICredential failed"
		exit 1
	}
    $UriComment = "$TCServerUrl/httpAuth/app/rest/latest/$TCBuildLocator/comment"
	try {
		Write-Verbose "Setting Comment using Invoke-RestMethod -Method PUT -Uri $UriComment -Credential $CICredential -Verbose"
		$TCResponse = Invoke-RestMethod -Method Put -Uri $UriComment -Credential $CICredential -Body $Comment -Verbose 
		Write-Verbose $TCResponse
		Return 
	}
	catch {
		Write-Host "$_" 
		Throw "[ERROR] Set-TeamCityBuildComment: $UriComment could not be set."
        exit 1
    }
}