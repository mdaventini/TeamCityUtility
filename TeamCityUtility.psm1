<#

.Author
.SYNOPSIS
.DESCRIPTION
.HELP 
	To recreate this run this commands
	New-ModuleManifest -Path "C:\Users\buildadmin\Documents\WindowsPowerShell\Modules\TeamCityUtility\TeamCityUtility.psd1" -Author "Mariela Daventini" -ModuleVersion 1.0.0 -Description "Functions for TeamCity" -PassThru -Verbose
	Set-Location -Path "C:\Users\buildadmin\Documents\WindowsPowerShell\Modules\TeamCityUtility"
	Publish-Module -Name .\TeamCityUtility.psd1 -Repository NexusRepoPSGallery -NuGetApiKey "306da3c9-beef-35d5-9931-de1e51ed92bc" -Verbose
#>

function Set-TeamCityParam {
	param(
		[parameter(Mandatory=$true, HelpMessage="Must be a valid TeamCity Url. Example -TCServerUrl 'http://tmcbuild01.helios.themls.com:8082'")] [String[]] $TCServerUrl, 
		[parameter(Mandatory=$true, HelpMessage="Valid UserName in TeamCity. Example -TCUser buildadmin")] [String[]] $TCUser,
		[parameter(Mandatory=$true, HelpMessage="Password for valid UserName in TeamCity. ")] [String[]] $TCSecret,
		[parameter(Mandatory=$true, HelpMessage="Parameter Locator. Example -TCParamLocator 'projects/id:_Root'")] [String[]] $TCParamLocator,
		[parameter(Mandatory=$true, HelpMessage="Parameter Name. Example -TCParamName 'env.DefaultEnvironmentBOC'")] [String[]] $TCParamName,
		[parameter(Mandatory=$true, HelpMessage="Parameter rawValue. Example -TCParamRaw select display='hidden' description='Default environment to deploy to when using Octopus. This is also defined by Team tennants.' data_2='QA' data_1='Dev' data_4='Sprint2' data_3='Sprint'")] [String[]] $TCParamRaw,
		[parameter(Mandatory=$true, HelpMessage="Parameter Value. Example -TCParamValue Sprint")] [String[]] $TCParamValue
	)
	try {
		Write-Host "Create CICredential"
		$CICredential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $TCUser, (ConvertTo-SecureString -String "$TCSecret" -AsPlainText -Force)
	}
	catch {
		Write-Host "$_" 
		Throw "[ERROR] TeamCityParams: Creating CICredential failed"
		exit 1
	}
    $ESValue = ""
    $ESRawValue = ""
    $UriParameter = "$TCServerUrl/httpAuth/app/rest/latest/$TCParamLocator/parameters/$TCParamName"
	try {
		Write-Host "Get Parameter"
		Write-Host "Will run Invoke-RestMethod -Method Get -Uri $UriParameter -Credential $CICredential -Verbose"
		$TCResponse = (Invoke-RestMethod -Method Get -Uri $UriParameter -Credential $CICredential)
        $ESValue = $TCResponse.property.value
        $ESRawValue = $TCResponse.property.type.rawValue
	}
	catch {
		Write-Host "$_" 
		Write-Host "$UriParameter does not exist ... creating"
        $JData = (@{value = "$TCParamValue"}) | ConvertTo-Json
		$TCResponse = ( Invoke-RestMethod -Method PUT -Uri $UriParameter -ContentType "application/json" -Credential $CICredential -Body $JData -Verbose )
        $ESValue = $TCResponse.property.value
     }
    Write-Host "Existing State is" $TCResponse.property.name $ESValue $ESRawValue
    try {
        if ( "$ESValue" -ne "$TCParamValue" ) {
    	    Write-Host "$UriParameter/value must be updated"
		    Write-Host "Will run Invoke-RestMethod -Method PUT -Uri $UriParameter/value -Credential $CICredential -Body $TCParamValue -Verbose"
		    $TCResponse = ( Invoke-RestMethod -Method PUT -Uri $UriParameter/value -Credential $CICredential -Body $TCParamValue -Verbose ) 
	    } else {
		    Write-Host "$UriParameter/value is up to date"
	    }
        if ( "$ESRawValue" -ne "$TCParamRaw" ) {
    	    Write-Host "$UriParameter/type/rawValue must be updated"
		    Write-Host "Will run Invoke-RestMethod -Method PUT -Uri $UriParameter/type/rawValue -Credential $CICredential -Body $TCParamRaw -Verbose"
		    $TCResponse = ( Invoke-RestMethod -Method PUT -Uri $UriParameter/type/rawValue -Credential $CICredential -Body $TCParamRaw -Verbose ) 
	    } else {
		    Write-Host "$UriParameter/type/rawValue is up to date"
	    }
	}
	catch {
        Write-Host "$_" 
		Write-Host "$UriParameter was not updated"
        exit 1
    }
}