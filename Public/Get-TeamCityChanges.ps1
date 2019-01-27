function Get-TeamCityChanges {
<#
	.SYNOPSIS
		Get changes in a TeamCity Instance by locator using VCS revision. Returns a TeamCity change object.
	.DESCRIPTION
		Uses Invoke-RestMethod get method.
	.Parameter TCServerUrl
		Specifies the url of a TeamCity Instance
	.Parameter TCVersion
		VCS Version number
	.EXAMPLE
		PS C:\> Get-TeamCityChanges -TCServerUrl 'http://TeamCity.yourdomain:8082' -TCVersion %build.vcs.number%
		PS C:\> Get-TeamCityChanges -TCServerUrl 'http://TeamCity.yourdomain:8082' -TCVersion 1970
#>
	[CmdletBinding()]
	param(
		[parameter(HelpMessage="Must be a valid TeamCity Url. Example -TCServerUrl 'http://TeamCity.yourdomain:8082'")][ValidateNotNullOrEmpty()][String[]]$TCServerUrl, 
		[parameter(HelpMessage="Version number. Example -TCVersion %build.vcs.number%")][ValidateNotNullOrEmpty()][String[]]$TCVersion
	)
	Write-Verbose "Get-TeamCityChanges"
	if ( $null -eq $TCCredential ) {
		Throw "[ERROR] Get-TeamCityChanges TCCredential is empty. Use [Set-TCCredential -TCUser <username> -TCSecret <password>]"
	}
	$Verbose = ($PSBoundParameters.ContainsKey('Verbose') -and $PsBoundParameters.Get_Item('Verbose'))
    $TCVersionChanges = @()
    $UriInvoke = "$TCServerUrl/httpAuth/app/rest/latest/changes/?locator=version:$TCVersion"
	try {
		Write-Verbose "Invoke-RestMethod Get $UriInvoke"
		$TCResponse = (Invoke-RestMethod -Method Get -Uri $UriInvoke -Credential $TCCredential -Verbose:$Verbose).changes.change
        ForEach ( $ThisChange in $TCResponse ) {
            $ChangeRef = $ThisChange.href
        	$UriInvoke = "$TCServerUrl$ChangeRef"
			Write-Verbose "Invoke-RestMethod Get $UriInvoke"
			$XmlChanges = (Invoke-RestMethod -Method Get -Uri $UriInvoke -Credential $TCCredential -Verbose:$Verbose).change
			ForEach ( $ThisChanges in $XmlChanges ) {
				$TCVersionChanges += New-Object -TypeName PSObject -Property @{
					ChangeComment = $ThisChanges.comment;
					ChangeUserName = $ThisChanges.username;
                    ChangeFile = $ThisChanges.files.file.file}
			}
		}
		$TCOutput = $TCVersionChanges | out-string
		Write-Verbose -Message "Change $TCOutput" 
		Return $TCVersionChanges
	}
	catch {
		Write-Host "$_" 
		Throw "[ERROR] Get-TeamCityChanges: $_"
        exit 1
    }
}