function Get-TeamCityProjects{
	param(
		[parameter(HelpMessage="Must be a valid TeamCity Url. Example -TCServerUrl 'http://TeamCity.yourdomain:8082'")][ValidateNotNullOrEmpty()][String[]]$TCServerUrl, 
		[parameter(HelpMessage="Valid UserName in TeamCity. Example -TCUser teamcityuser")][ValidateNotNullOrEmpty()][String[]]$TCUser,
		[parameter(HelpMessage="Password for valid UserName in TeamCity. ")][ValidateNotNullOrEmpty()][String[]]$TCSecret
	)
	Write-Verbose "Get-TeamCityProjects"
	try {
		Write-Verbose "Creating CICredential for $TCUser"
		$CICredential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $TCUser, (ConvertTo-SecureString -String "$TCSecret" -AsPlainText -Force)
	}
	catch {
		Write-Host "$_" 
		Throw "[ERROR] Get-TeamCityProjects: Creating CICredential failed"
		exit 1
	}
    $UriTeamCity = "$TCServerUrl/httpAuth/app/rest/latest/projects"
	try {
		$ErrorMessage = "$UriTeamCity does not exist."
		Write-Verbose "Getting Projects using Invoke-RestMethod -Method Get -Uri $UriTeamCity -Credential $CICredential -Verbose"
		$TCResponse = (Invoke-RestMethod -Method Get -Uri $UriTeamCity -Credential $CICredential -Verbose).projects.project | Select-Object -Property Name, href
		$ErrorMessage = "Parsing $TCResponse"
		$TCResponse | out-string
		Write-Verbose -Message "Projects" 
		$ErrorMessage = "Returning $TCResponse"
		Return $TCResponse
	}
	catch {
		Write-Host "$_" 
		Throw "[ERROR] Get-TeamCityProjects: $ErrorMessage"
        exit 1
    }
}