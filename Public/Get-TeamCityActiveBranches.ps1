function Get-TeamCityActiveBranches{
	param(
		[parameter(HelpMessage="Must be a valid TeamCity Url. Example -TCServerUrl 'http://TeamCity.yourdomain:8082'")][ValidateNotNullOrEmpty()][String[]]$TCServerUrl, 
		[parameter(HelpMessage="Valid UserName in TeamCity. Example -TCUser teamcityuser")][ValidateNotNullOrEmpty()][String[]]$TCUser,
		[parameter(HelpMessage="Password for valid UserName in TeamCity. ")][ValidateNotNullOrEmpty()][String[]]$TCSecret,
		[parameter(HelpMessage="Array with branches pattern to select. Example -TCBranchesPattern '@('^2.*-*', '^3.*-*')'")][ValidateNotNullOrEmpty()][String[]]$TCBranchesPattern
	)
	Write-Verbose "Get-TeamCityActiveBranches $TCBranchesPattern"
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
	try {
		$TCResponse = (Get-TeamCityProjects -TCServerUrl $TCServerUrl -TCUser $TCUser -TCSecret $TCSecret -Verbose)
		ForEach ( $ThisProject in $TCResponse ) {
			$ProjName = $ThisProject.Name
			$ProjHRef = $ThisProject.href
			$UriInvoke = "$TCServerUrl$ProjHRef/branches"
			Write-Verbose "Invoke-RestMethod Get $UriInvoke"
			$XmlProjectBranches = ((Invoke-RestMethod -Method Get -Uri $UriInvoke -Credential $CICredential -Verbose).branches.branch.name )
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