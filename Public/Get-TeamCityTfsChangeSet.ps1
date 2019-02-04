function Get-TeamCityTfsChangeSet{
<#
	.SYNOPSIS
		Get changes in TFS by version. Returns a list of projects or full detail with -TCDetailed $true
	.DESCRIPTION
		Uses add-pssnapin Microsoft.TeamFoundation.PowerShell (Get-TfsServer and Get-TfsChangeSet)
	.Parameter TCTFSServerUrl
		Specifies the url of a TFS collection
	.Parameter TCTFSChangeSet
		ChangeSet number
	.Parameter TCProjectsInCI
		Specifies an array with projects to return
	.Parameter TCDetailed
		Specifies if will return detailed data
	.EXAMPLE
		PS C:\> Get-TeamCityTfsChangeSet -TCTFSServerUrl 'http://mytfs:8080/tfs/MyCollection' -TCTFSChangeSet %build.vcs.number% -TCProjectsInCI @( 'FirstProject', 'SecondProject', 'DependantProject') -TCDetailed $true
		Will return a list of changes for the given vcs number from TeamCity and select projects
		Please use -TCTFSServerUrl format as 'TFS 2010+: http[s]://<TFS Server>:<Port>/tfs/<Collection Name>'
	.EXAMPLE
		PS C:\> Get-TeamCityTfsChangeSet -TCTFSServerUrl 'http://mytfs:8080/tfs/MyCollection' -TCTFSChangeSet 1970 -TCProjectsInCI @( 'FirstProject', 'SecondProject', 'DependantProject')
		Will return a list of changes for the given vcs number from TeamCity and select projects
#>
	[CmdletBinding()]
	param(
		[parameter(HelpMessage="Must be a valid Tfs Url. Use Get-Help Get-TeamCityTfsChangeSet -Examples to see examples")][ValidateNotNullOrEmpty()][String[]]$TCTFSServerUrl, 
		[parameter(HelpMessage="ChangeSet number. Use Get-Help Get-TeamCityTfsChangeSet -Examples to see examples")][ValidateNotNullOrEmpty()][Int]$TCTFSChangeSet,
		[parameter(HelpMessage="Array of TFS Project Names. Use Get-Help Get-TeamCityTfsChangeSet -Examples to see examples")][ValidateNotNullOrEmpty()][String[]]$TCProjectsInCI,
		[parameter(HelpMessage="Use -TCDetailed to get full detail of files in commit. Example -TCDetailed")][Switch]$TCDetailed
	)
	Write-Verbose "Get-TeamCityTfsChangeSet"
	add-pssnapin Microsoft.TeamFoundation.PowerShell
	if ( $null -eq $TCCredential ) {
		Throw "[ERROR] Get-TeamCityTfsChangeSet TCCredential is empty. Use [Set-TCCredential -TCUser <username> -TCSecret <password>]"
	}
	$Verbose = ($PSBoundParameters.ContainsKey('Verbose') -and $PsBoundParameters.Get_Item('Verbose'))
	try {
		Write-Verbose "Getting TFSChanges using -TCTFSServerUrl $TCTFSServerUrl -TCTFSChangeSet $TCTFSChangeSet"
		$ProjectsInCommit = @()
		$ThisTFSServer = Get-TfsServer -name "$TCTFSServerUrl" -Credential $TCCredential -Verbose:$Verbose
		$ThisChangeSet = Get-TfsChangeSet -ChangesetNumber $TCTFSChangeSet -Server $ThisTFSServer -Verbose:$Verbose
		ForEach ($ThisChange in $ThisChangeSet.Changes) {
			$ThisFile = ($ThisChange.Item.ServerItem).Remove(0,2)
			$ThisProjectEndIndex = $ThisFile.IndexOf('/')
			$ThisProject = $ThisFile.Substring(0, $ThisProjectEndIndex)
			if ( ( $TCProjectsInCI -contains $ThisProject ) -or ( -not $TCProjectsInCI ) ) {
				if ($ProjectsInCommit -notcontains $ThisProject) {
					$ProjectsInCommit += $ThisProject
				}
			}
		}
		If ( $TCDetailed ) {
			Write-Verbose -Message "Will return Details In Commit" 
			$ProjectsInCommit = $ThisChangeSet | Select-Object -Property Committer, Comment -ExpandProperty Changes | Select-Object -Property Committer, Comment -ExpandProperty Item | Select-Object * 
		}
		$TCOutput = $ProjectsInCommit | out-string
		Write-Verbose -Message "ProjectsInCommit $TCOutput" 
		Return $ProjectsInCommit
	}
	catch {
		Write-Host "$_" 
		Throw "[ERROR] Get-TeamCityTfsChangeSet"
		exit 1
	}
}