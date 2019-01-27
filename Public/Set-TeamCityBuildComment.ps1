function Set-TeamCityBuildComment {
<#
	.SYNOPSIS
		Set a TeamCity build comment by BuildLocator.
	.DESCRIPTION
		Uses Invoke-RestMethod put method.
	.Parameter TCServerUrl
		Specifies the url of a TeamCity Instance
	.Parameter TCBuildLocator
		Specifies the buid locator
	.Parameter Comment
		Specifies the comment to set
	.EXAMPLE
		PS C:\> Set-TeamCityBuildComment -TCServerUrl 'http://TeamCity.yourdomain:8082' -TCBuildLocator 'builds/id:1970' -Comment 'Triggered by ...'
#>
	[CmdletBinding()]
	param(
		[parameter(HelpMessage="Must be a valid TeamCity Url. Example -TCServerUrl 'http://TeamCity.yourdomain:8082'")][ValidateNotNullOrEmpty()][String[]]$TCServerUrl, 
		[parameter(HelpMessage="Build Locator. Example -TCBuildLocator 'builds/id:1970'")][ValidateNotNullOrEmpty()][String[]]$TCBuildLocator,
		[parameter(HelpMessage="Comment. Example -Comment 'Triggered by ...'")][ValidateNotNullOrEmpty()][String[]]$Comment
	)
	Write-Verbose "Set-TeamCityBuildComment"
	if ( $null -eq $TCCredential ) {
		Throw "[ERROR] Set-TeamCityBuildComment TCCredential is empty. Use [Set-TCCredential -TCUser <username> -TCSecret <password>]"
	}
	$Verbose = ($PSBoundParameters.ContainsKey('Verbose') -and $PsBoundParameters.Get_Item('Verbose'))
    $UriInvoke = "$TCServerUrl/httpAuth/app/rest/latest/$TCBuildLocator/comment"
	try {
		Write-Verbose "Invoke-RestMethod PUT $UriInvoke"
		$TCResponse = Invoke-RestMethod -Method Put -Uri $UriInvoke -Credential $TCCredential -Body $Comment -Verbose:$Verbose 
		Write-Verbose $TCResponse
		Return 
	}
	catch {
		Write-Host "$_" 
		Throw "[ERROR] Set-TeamCityBuildComment: $UriComment could not be set."
        exit 1
    }
}