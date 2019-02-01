function Get-TeamCityVCSProblems{
<#
	.SYNOPSIS
		Gets problemOccurrences in builds (filtering last 60 minutes sinceDate). Shows problemOccurrences.details. if -TCFix $true fixes found problems
	.DESCRIPTION
		Uses Invoke-RestMethod get to get all problemOccurrences since a given date from now.
		Checks if the details error contains 'Failed to collect changes, error: Error collecting changes for VCS repository' and 'jetbrains.buildServer.util.graph.CycleDetectedException: Cycle found between'
		Parses repository name and instance from details
		Uses Invoke-RestMethod DELETE repositoryState to fix the problem in the vcs-root-instance
	.Parameter TCServerUrl
		Specifies the url of a TeamCity Instance
	.Parameter TCSinceDate
		Specifies start date to check builds
	.Parameter TCFix
		Specifies if will fix problems
	.EXAMPLE
		Get-TeamCityVCSProblems -TCServerUrl 'http://TeamCity.yourdomain:8082'
        Get all data
	.EXAMPLE
		Get-TeamCityVCSProblems -TCServerUrl 'http://TeamCity.yourdomain:8082' -TCSinceDate 19701024T164500-0300
        Get data since a particular date
	.EXAMPLE
		Get-TeamCityVCSProblems -TCServerUrl 'http://TeamCity.yourdomain:8082' -TCFix
		Fix all problems
	.EXAMPLE
		Get-TeamCityVCSProblems -TCServerUrl 'http://TeamCity.yourdomain:8082' -TCSinceDate 19701024T164500-0300 -TCFix
        Fix all problems since a particular date
#>
	[CmdletBinding()]
	param(
		[parameter(HelpMessage="Must be a valid TeamCity Url. Example -TCServerUrl 'http://TeamCity.yourdomain:8082'")][ValidateNotNullOrEmpty()][String[]]$TCServerUrl,
		[parameter(HelpMessage="Must be a TeamCity timestamp with format 'yyyyMMddTHHmmsszzz'. Example -TCSinceDate 19701024T164500-0300")][ValidateNotNullOrEmpty()][String[]]$TCSinceDate,		
		[parameter(HelpMessage="Use -TCFix to fix problems.")][Switch]$TCFix
	)
	Write-Verbose "Get-TeamCityVCSProblems"
	if ( $null -eq $TCCredential ) {
		Throw "[ERROR] Get-TeamCityBuildsByRevision TCCredential is empty. Use [Set-TCCredential -TCUser <username> -TCSecret <password>]"
	}
	$Verbose = ($PSBoundParameters.ContainsKey('Verbose') -and $PsBoundParameters.Get_Item('Verbose'))
	try {
		if ( $TCSinceDate ) {
            $SinceDate = ",sinceDate:$TCSinceDate"
        }
		$UriInvoke = "$TCServerUrl/httpAuth/app/rest/latest/problemOccurrences?locator=build:(failedToStart:true$SinceDate)&fields=problemOccurrence(details)"
		Write-Verbose "Invoke-RestMethod Get $UriInvoke"
		$FailureFirst = "Failed to collect changes, error: Error collecting changes for VCS repository"
		$FailureSecond = "jetbrains.buildServer.util.graph.CycleDetectedException: Cycle found between"
		$TCResponse = (Invoke-RestMethod -Method Get -Uri $UriInvoke -Credential $TCCredential -Verbose:$Verbose).problemOccurrences.problemOccurrence | Where-Object { ($_.details -match $FailureFirst -and $_.details -match $FailureSecond) } | Sort-Object -Property details -Unique
		$ProblemsFound = $false
		$TCResponse | ForEach {
			$ProblemsFound = $true
			$VCSRepositoryName = (($_.details).Split("'")[1].Split(" {")[0]).Replace("`"","")
			$VCSId = ($_.details).Replace("`"","").Replace("'","").Replace("`n"," ").Split("=")[1].Split(",")[0]
			if ( $TCFix ) {
				$UriInvokeFix = "$TCServerUrl/httpAuth/app/rest/latest/vcs-root-instances/id:$VCSId/repositoryState"
				Write-Host "$VCSRepositoryName will be fixed: Invoke-RestMethod DELETE $UriInvokeFix" 
				Invoke-RestMethod -Method DELETE $UriInvokeFix -Credential $TCCredential -Verbose:$Verbose   
			} 
			else {
				Write-Host "$VCSRepositoryName has problems and need to be fixed" 
			} 
		}
		Write-Verbose -Message "Done! " 
		if ( $ProblemsFound -and -not $Fix ) {
			Write-Verbose -Message "Will return message" 
			Return "Please run Get-TeamCityVCSProblems -TCServerUrl 'http://mytfs:8080/tfs/MyCollection' -TCFix to fix found problems"
		}
		#Return $false for no problems found or fixed
		Write-Verbose -Message "Will return false" 
		Return $false
	}
	catch {
		Write-Host "$_" 
		Throw "[ERROR] Get-TeamCityVCSProblems: $_"
		exit 1
	}
}