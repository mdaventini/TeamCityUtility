function Check-TeamCityVCSCycleFound{
<#
	.SYNOPSIS
		Check vcs-root-instances. Shows status of all instances. if -Fix $true fixes the problem
	.DESCRIPTION
		Uses Invoke-RestMethod get to get all vcs-root-instances.
		Checks 'vcs-root-instance'.status.current
		If Status is started and timestamp is older than 1 hour, means it's broken
		Uses Invoke-RestMethod DELETE repositoryState to fix the problem
	.Parameter TCTFSServerUrl
		Specifies the url of a TFS collection
	.Parameter TCRepositoryNameId
		Specifies a VCS repository Name
	.Parameter Fix
		Specifies if will fix problems
	.EXAMPLE
		PS C:\> Check-TeamCityVCSCycleFound -TCTFSServerUrl 'http://mytfs:8080/tfs/MyCollection' -TCRepositoryNameId 'MyRepo' -Fix
		
		PS C:\> Check-TeamCityVCSCycleFound -TCTFSServerUrl 'http://mytfs:8080/tfs/MyCollection' 
#>
	[CmdletBinding()]
	param(
		[parameter(HelpMessage="Must be a valid Tfs Url. Example -TCTFSServerUrl 'TFS 2010+: http[s]://<TFS Server>:<Port>/tfs/<Collection Name>'")][ValidateNotNullOrEmpty()][String[]]$TCTFSServerUrl, 
		[parameter(HelpMessage="Must be a valid VCS repository Name Id or nothing. Example -TCRepositoryNameId MyRepo")][ValidateNotNullOrEmpty()][String[]]$TCRepositoryNameId,
		[parameter(HelpMessage="Use -Fix to fix problems. Example -Fix")][Switch]$Fix
	)
	Write-Verbose "Check-TeamCityVCSCycleFound -TCRepositoryNameId $TCRepositoryNameId"
	if ( $null -eq $TCCredential ) {
		Throw "[ERROR] Get-TeamCityBuildsByRevision TCCredential is empty. Use [Set-TCCredential -TCUser <username> -TCSecret <password>]"
	}
	$Verbose = ($PSBoundParameters.ContainsKey('Verbose') -and $PsBoundParameters.Get_Item('Verbose'))
	try {
		$AnHourEarlier = ((Get-Date).AddMinutes(-1)).ToString("yyyyMMddTHHmmss")
		if ( $TCRepositoryNameId ) {
			$UriInvoke = "$TCServerUrl/httpAuth/app/rest/latest/vcs-root-instances?locator=vcsRoot:($TCRepositoryNameId)"
		}
		else {
			$UriInvoke = "$TCServerUrl/httpAuth/app/rest/latest/vcs-root-instances"
		}
		Write-Verbose "Invoke-RestMethod Get $UriInvoke"
		(Invoke-RestMethod -Method Get -Uri $UriInvoke -Credential $TCCredential -Verbose:$Verbose).'vcs-root-instances'.'vcs-root-instance' | ForEach {
			#Check each one
			$VCSName = $_.name
			$VCSId = $_.id
			$UriInvoke = "$TCServerUrl/httpAuth/app/rest/latest/vcs-root-instances/id:$VCSId"
			Write-Verbose "Invoke-RestMethod Get $UriInvoke"
			$VCSCurrentStatus = ( (Invoke-RestMethod -Method Get -Uri $UriInvoke -Credential $TCCredential -Verbose:$Verbose).'vcs-root-instance'.status.current ) 
			Write-Verbose "Checking status for $VCSName Invoke-RestMethod Get $UriInvoke"
			###Only clean if Status is started and timestamp must be at least 1 hour older
			$VCSCurrentStatus | ForEach {
				$VCSCurrentStatus =  $_.status 
				$VCSTimeStamp = $_.timestamp
				Write-Verbose "$VCSName Status is $VCSCurrentStatus since $VCSTimeStamp" 
				if ( $VCSCurrentStatus -eq "started" -and  $AnHourEarlier -gt $VCSTimeStamp ) {
					Write-Host "$VCSName Status is $VCSCurrentStatus since $VCSTimeStamp and need to be fixed" 
					$UriInvokeFix = "$TCServerUrl/httpAuth/app/rest/latest/vcs-root-instances/id:$VCSId/repositoryState"
					if ( $Fix ) {
						Write-Host "$VCSName will be fixed as Status is $VCSCurrentStatus since $VCSTimeStamp Invoke-RestMethod DELETE $UriInvokeFix" 
						Invoke-RestMethod -Method DELETE $UriInvokeFix -Credential $TCCredential -Verbose   
					}
				}
			}
		}
		Write-Verbose -Message "Done! " 
	}
	catch {
		Write-Host "$_" 
		Throw "[ERROR] Get-TeamCityBuildsByRevision: $_"
		exit 1
	}
}