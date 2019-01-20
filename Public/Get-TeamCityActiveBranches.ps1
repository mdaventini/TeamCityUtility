function Get-TeamCityActiveBranches{
	param(
		[parameter(HelpMessage="Must be a valid TeamCity Url. Example -TCServerUrl 'http://TeamCity.yourdomain:8082'")][ValidateNotNullOrEmpty()][String[]]$TCServerUrl, 
		[parameter(HelpMessage="Valid UserName in TeamCity. Example -TCUser teamcityuser")][ValidateNotNullOrEmpty()][String[]]$TCUser,
		[parameter(HelpMessage="Password for valid UserName in TeamCity. ")][ValidateNotNullOrEmpty()][String[]]$TCSecret,
		[parameter(HelpMessage="Branches pattern to select. Example -TCBranchesPattern '2.*-*'")][ValidateNotNullOrEmpty()][String[]]$TCBranchesPattern
	)
	Write-Verbose "Get-TeamCityActiveBranches"
	<#
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
		Write-Verbose "Getting Prjects using Get-TeamCityProjects -TCServerUrl $TCServerUrl"
		$TCResponse = (Get-TeamCityProjects -TCServerUrl $TCServerUrl -TCUser $TCUser -TCSecret $TCSecret -Verbose).projects.project
		Write-Verbose $TCResponse
		ForEach ( $ThisProject in ($TCResponse | Select-Object -Property name, href) ) {
			$XmlProjectBranches = (Invoke-RestMethod -Method Get -Uri ($TCServerUrl + $ThisProject.href + "/branches") -Credential $CICredential -Verbose).branches.branch | Where-Object { ( $_.name -Match $TCBranchesPattern) }
			ForEach ( $ThisProjectBranches in $XmlProjectBranches) {
				$AllActiveBranches += New-Object –TypeName PSObject -Property @{
					ProjectName = $ThisProject.name;
					Branch = $ThisProjectBranches.name}
			}
		}
		Write-Verbose $AllActiveBranches
		Return $AllActiveBranches
	}
	catch {
		Write-Host "$_" 
		Throw "[ERROR] Get-TeamCityActiveBranches"
        exit 1
    }
	#>
}