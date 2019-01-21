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
        Write-Verbose $SavePoint
		ForEach ( $ThisProject in $TCResponse) {
            $ProjName = $ThisProject.Name
            $ProjHRef = $ThisProject.href
			$SavePoint = "For Each Project $ProjName $ProjHRef" 
			$UriTeamCity = "$TCServerUrl$ProjHRef/branches"
            Write-Verbose $SavePoint
			$XmlProjectBranches = (Invoke-RestMethod -Method Get -Uri $UriTeamCity -Credential $CICredential -Verbose).branches.branch | Where-Object { ( $_.name -Match $TCBranchesPattern) } | Select-Object -Property Name 
			ForEach ( $ThisProjectBranches in $XmlProjectBranches) {
				$SavePoint = "For Each Branch in $ProjName"
                $BranchName = $ThisProjectBranches.Name
				Write-Verbose "$SavePoint branch $BranchName"
				$AllActiveBranches += New-Object –TypeName PSObject -Property @{
					ProjectName = $ProjName;
					Branch = $BranchName}
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