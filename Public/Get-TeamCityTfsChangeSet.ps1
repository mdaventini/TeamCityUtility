function Get-TeamCityTfsChangeSet{
<#
	.SYNOPSIS
		Get changes in TFS by version. Returns a list of projects.
	.DESCRIPTION
		Uses add-pssnapin Microsoft.TeamFoundation.PowerShell (Get-TfsServer and Get-TfsChangeSet)
	.Parameter TCTFSServerUrl
		Specifies the url of a TFS collection
	.Parameter TCTFSChangeSet
		ChangeSet number
	.Parameter TCProjectsInCI
		Specifies an array with projects to return
	.EXAMPLE
		PS C:\> Get-TeamCityTfsChangeSet -TCTFSServerUrl 'http://mytfs:8080/tfs/MyCollection' -TCTFSChangeSet %build.vcs.number% -TCProjectsInCI @( 'FirstProject', 'SecondProject', 'DependantProject')
		PS C:\> Get-TeamCityTfsChangeSet -TCTFSServerUrl 'http://mytfs:8080/tfs/MyCollection' -TCTFSChangeSet 1970 -TCProjectsInCI @( 'FirstProject', 'SecondProject', 'DependantProject')
#>
	[CmdletBinding()]
	param(
		[parameter(HelpMessage="Must be a valid Tfs Url. Example -TCTFSServerUrl 'TFS 2010+: http[s]://<TFS Server>:<Port>/tfs/<Collection Name>'")][ValidateNotNullOrEmpty()][String[]]$TCTFSServerUrl, 
		[parameter(HelpMessage="ChangeSet number. Example -TCTFSChangeSet 1970")][ValidateNotNullOrEmpty()][String[]]$TCTFSChangeSet,
		[parameter(HelpMessage="Array of TFS Project Names. Example -TCProjectsInCI @( 'FirstProject', 'SecondProject', 'DependantProject')")][ValidateNotNullOrEmpty()][String[]]$TCProjectsInCI
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
		$ThisTFSServer = Get-TfsServer -name $TCTFSServerUrl -Credential $TCCredential -Verbose:$Verbose
		$ThisChangeSet = Get-TfsChangeSet -ChangesetNumber $TCTFSChangeSet -Server $ThisTFSServer -Verbose:$Verbose
		ForEach ($ThisChange in $ThisChangeSet.Changes) {
			$ThisFile = ($ThisChange.Item.ServerItem).Remove(0,2)
			$ThisProjectEndIndex = $ThisFile.IndexOf('/')
			$ThisProject = $ThisFile.Substring(0, $ThisProjectEndIndex)
			if ($TCProjectsInCI -contains $ThisProject) {
				if ($ProjectsInCommit -notcontains $ThisProject) {
					$ProjectsInCommit += $ThisProject
				}
			}
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