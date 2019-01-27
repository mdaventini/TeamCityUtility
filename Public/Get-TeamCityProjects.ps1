function Get-TeamCityProjects{
<#
	.SYNOPSIS
		Get all projects in TeamCity and returns a TeamCity projects.project Name and href.
	.DESCRIPTION
		Uses Invoke-RestMethod get method.
	.Parameter TCServerUrl
		Specifies the url of a TeamCity Instance
	.EXAMPLE
		PS C:\> Get-TeamCityProjects -TCServerUrl 'http://TeamCity.yourdomain:8082'
#>
	[CmdletBinding()]
	param(
		[parameter(HelpMessage="Must be a valid TeamCity Url. Example -TCServerUrl 'http://TeamCity.yourdomain:8082'")][ValidateNotNullOrEmpty()][String[]]$TCServerUrl 
	)
	Write-Verbose "Get-TeamCityProjects"
	if ( $null -eq $TCCredential ) {
		Throw "[ERROR] Get-TeamCityProjects TCCredential is empty. Use [Set-TCCredential -TCUser <username> -TCSecret <password>]"
	}
	$Verbose = ($PSBoundParameters.ContainsKey('Verbose') -and $PsBoundParameters.Get_Item('Verbose'))
    $UriInvoke = "$TCServerUrl/httpAuth/app/rest/latest/projects"
	try {
		Write-Verbose "Invoke-RestMethod Get $UriInvoke"
		$TCResponse = (Invoke-RestMethod -Method Get -Uri $UriInvoke -Credential $TCCredential -Verbose:$Verbose).projects.project | Select-Object -Property Name, href
		$TCOutput = $TCResponse | out-string
		Write-Verbose -Message "Projects $TCOutput" 
		Return $TCResponse
	}
	catch {
		Write-Host "$_" 
		Throw "[ERROR] Get-TeamCityProjects: $UriInvoke does not exist."
        exit 1
    }
}