function Get-TeamCityActiveBranches{
	param(
		[parameter(HelpMessage="Must be a valid TeamCity Url. Example -TCServerUrl 'http://TeamCity.yourdomain:8082'")][ValidateNotNullOrEmpty()][String[]]$TCServerUrl, 
		[parameter(HelpMessage="Valid UserName in TeamCity. Example -TCUser teamcityuser")][ValidateNotNullOrEmpty()][String[]]$TCUser,
		[parameter(HelpMessage="Password for valid UserName in TeamCity. ")][ValidateNotNullOrEmpty()][String[]]$TCSecret,
		[parameter(HelpMessage="Branches pattern to select. Example -TCBranchesPattern '2.*-*'")][ValidateNotNullOrEmpty()][String[]]$TCBranchesPattern
	)
	Write-Verbose "Get-TeamCityActiveBranches"
	try {
		Write-Verbose "Creating CICredential for $TCUser"
		$CICredential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $TCUser, (ConvertTo-SecureString -String "$TCSecret" -AsPlainText -Force)
	}
	catch {
		Write-Host "$_" 
		Throw "[ERROR] Get-TeamCityActiveBranches: Creating CICredential failed"
		exit 1
	}
	$AllActiveBranches = @()
	$SavePoint = "Before Get-TeamCityProjects"
	try {
		Write-Verbose "Getting Projects using Get-TeamCityProjects -TCServerUrl $TCServerUrl"
		$TCResponse = (Get-TeamCityProjects -TCServerUrl $TCServerUrl -TCUser $TCUser -TCSecret $TCSecret -Verbose)
		$SavePoint = "After Get-TeamCityProjects"
		ForEach ( $ThisProject in $TCResponse ) {
			$SavePoint = "For Each Project $ThisProject.href"
			$UriTeamCity = "$TCServerUrl$ThisProject.href/branches"
			$XmlProjectBranches = (Invoke-RestMethod -Method Get -Uri $UriTeamCity -Credential $CICredential -Verbose).branches.branch | Where-Object { ( $_.name -Match $TCBranchesPattern) }
			ForEach ( $ThisProjectBranches in $XmlProjectBranches) {
				$SavePoint = "For Each Branch $ThisProjectBranches.name"
				$AllActiveBranches += New-Object –TypeName PSObject -Property @{
					ProjectName = $ThisProject.name;
					Branch = $ThisProjectBranches.name}
			}
		}
		$TCOutput = $AllActiveBranches | out-string
		Write-Verbose -Message "AllActiveBranches $TCOutput" 
		Return $AllActiveBranches
	}
	catch {
		Write-Host "$_" 
		Throw "[ERROR] Get-TeamCityActiveBranches $SavePoint"
        exit 1
    }
}