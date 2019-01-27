function Get-TeamCityActiveBranches{
<#
	.SYNOPSIS
		Get all active branches on all projects in a TeamCity Instance filtering by a given array of patterns. Returns all active branches by project name.
	.DESCRIPTION
		Uses Get-TeamCityProjects and Invoke-RestMethod get method.
	.Parameter TCServerUrl
		Specifies the url of a TeamCity Instance
	.Parameter TCBranchesPattern
		Specifies an array with branches pattern to select
	.EXAMPLE
		PS C:\> Get-TeamCityActiveBranches -TCServerUrl 'http://TeamCity.yourdomain:8082' -TCBranchesPattern '@('^2.*-*', '^3.*-*')'
#>
	[CmdletBinding()]
	param(
		[parameter(HelpMessage="Must be a valid TeamCity Url. Example -TCServerUrl 'http://TeamCity.yourdomain:8082'")][ValidateNotNullOrEmpty()][String[]]$TCServerUrl, 
		[parameter(HelpMessage="Array with branches pattern to select. Example -TCBranchesPattern '@('^2.*-*', '^3.*-*')'")][ValidateNotNullOrEmpty()][String[]]$TCBranchesPattern
	)
	Write-Verbose "Get-TeamCityActiveBranches $TCBranchesPattern"
	if ( $null -eq $TCCredential ) {
		Throw "[ERROR] Get-TeamCityBuildsByRevision TCCredential is empty. Use [Set-TCCredential -TCUser <username> -TCSecret <password>]"
	}
	$Verbose = ($PSBoundParameters.ContainsKey('Verbose') -and $PsBoundParameters.Get_Item('Verbose'))
	$AllActiveBranches = @()
	try {
		$TCResponse = (Get-TeamCityProjects -TCServerUrl $TCServerUrl -Verbose:$Verbose)
		ForEach ( $ThisProject in $TCResponse ) {
			$ProjName = $ThisProject.Name
			$ProjHRef = $ThisProject.href
			$UriInvoke = "$TCServerUrl$ProjHRef/branches"
			Write-Verbose "Invoke-RestMethod Get $UriInvoke"
			$XmlProjectBranches = ((Invoke-RestMethod -Method Get -Uri $UriInvoke -Credential $TCCredential -Verbose:$Verbose).branches.branch.name )
			ForEach ( $ThisProjectBranches in $XmlProjectBranches ) {
				$BranchName = $ThisProjectBranches
				ForEach ( $ThisPattern in $TCBranchesPattern) {
					if ( $BranchName -Match $ThisPattern  ) {
						$AllActiveBranches += New-Object -TypeName PSObject -Property @{
							ProjectName = $ProjName;
							Branch = $BranchName}
					}
				}
			}
		}
		$TCOutput = $AllActiveBranches | out-string
		Write-Verbose -Message "AllActiveBranches $TCOutput" 
		Return $AllActiveBranches
	}
	catch {
		Write-Host "$_" 
		Throw "[ERROR] Get-TeamCityActiveBranches $_"
		exit 1
	}
}