function Get-TeamCityTfsChangeSet{
	param(
		[parameter(HelpMessage="Must be a valid Tfs Url. Example -TCTFSServerUrl 'TFS 2010+: http[s]://<TFS Server>:<Port>/tfs/<Collection Name>'")][ValidateNotNullOrEmpty()][String[]]$TCTFSServerUrl, 
		[parameter(HelpMessage="Valid UserName in TeamCity. Example -TCUser teamcityuser")][ValidateNotNullOrEmpty()][String[]]$TCUser,
		[parameter(HelpMessage="Password for valid UserName in TeamCity. ")][ValidateNotNullOrEmpty()][String[]]$TCSecret,
		[parameter(HelpMessage="ChangeSet number. Example -TCTFSChangeSet 1970")][ValidateNotNullOrEmpty()][String[]]$TCTFSChangeSet,
		[parameter(HelpMessage="Array of TFS Project Names. Example -TCProjectsInCI @( 'FirstProject', 'SecondProject', 'DependantProject')")][ValidateNotNullOrEmpty()][String[]]$TCProjectsInCI
	)
	Write-Verbose "Get-TeamCityTfsChangeSet"
	add-pssnapin Microsoft.TeamFoundation.PowerShell
	try {
		Write-Verbose "Creating CICredential for $TCUser"
		$CICredential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $TCUser, (ConvertTo-SecureString -String "$TCSecret" -AsPlainText -Force)
	}
	catch {
		Write-Host "$_" 
		Throw "[ERROR] Get-TeamCityTfsChangeSet: Creating CICredential failed"
		exit 1
	}
	try {
		Write-Verbose "Getting TFSChanges using -TCTFSServerUrl $TCTFSServerUrl -TCTFSChangeSet $TCTFSChangeSet"
		$ProjectsInCommit = @()
		$ThisTFSServer = Get-TfsServer -name $TCTFSServerUrl -Credential $CICredential -Verbose
		$ThisChangeSet = Get-TfsChangeSet -ChangesetNumber $TCTFSChangeSet -Server $ThisTFSServer
		ForeEch ($ThisChange in $ThisChangeSet.Changes) {
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