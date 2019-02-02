function Invoke-TeamCityRESTAPI{
<#
	.SYNOPSIS
		Generic invoke.
	.DESCRIPTION
		Uses Invoke-RestMethod for a given method and uri.
	.Parameter TCMethod
		Specifies the method to invoke, ValidateSet: GET, PUT, DELETE
	.Parameter TCUri
		Specifies the uri to invoke
	.Parameter TCBody
		Specifies the value for -Body
	.EXAMPLE
		Invoke-TeamCityRESTAPI -TCMethod GET -TCUri /httpAuth/app/rest/latest/problemOccurrences?locator=build:(failedToStart:true)`&fields=problemOccurrence(details) 
        Get problemOccurrences by locator and return xml
	.EXAMPLE
		Invoke-TeamCityRESTAPI -TCMethod PUT -TCUri /httpAuth/app/rest/latest/<ParamLocator>/parameters/<ParamName> -TCBody "this value"
        PUT "this value" in ParamName for a given ParamLocator
	.EXAMPLE
		Invoke-TeamCityRESTAPI -TCMethod DETELE -TCUri /httpAuth/app/rest/latest/vcs-root-instances/id:999/repositoryState
        DELETE repositoryState for a given vcs-root-instances id
#>
	[CmdletBinding()]
	param(
		[parameter(HelpMessage="Must be a valid Method. Use Get-Help Invoke-TeamCityRESTAPI -Examples to see examples")][ValidateSet("GET","PUT","DELETE")][String]$TCMethod,
		[parameter(HelpMessage="Must be a valid TeamCity uri. Use Get-Help Invoke-TeamCityRESTAPI -Examples to see examples")][ValidateNotNullOrEmpty()][String]$TCUri,
		[parameter(HelpMessage="Must be a string for -TCMethod PUT. Use Get-Help Invoke-TeamCityRESTAPI -Examples to see examples")][ValidateNotNullOrEmpty()][String]$TCBody
	)
	Write-Verbose "Invoke-TeamCityRESTAPI"
	if ( $null -eq $TCCredential ) {
		Throw "[ERROR] Invoke-TeamCityRESTAPI TCCredential is empty. Use [Set-TCCredential -TCUser <username> -TCSecret <password>]"
	}
	$Verbose = ($PSBoundParameters.ContainsKey('Verbose') -and $PsBoundParameters.Get_Item('Verbose'))
	try {
		#Only for PUT
		if ( $TCBody ) {
		    Write-Verbose "Command is Invoke-RestMethod -Method $TCMethod -Uri $TCUri -Body $TCBody -Credential $TCCredential -Verbose:$Verbose"
		    $TCResponse = Invoke-RestMethod -Method $TCMethod -Uri $TCUri -Body $TCBody -Credential $TCCredential -Verbose:$Verbose
        } 
        else {
		    Write-Verbose "Command is Invoke-RestMethod -Method $TCMethod -Uri $TCUri -Credential $TCCredential -Verbose:$Verbose"
		    $TCResponse = Invoke-RestMethod -Method $TCMethod -Uri $TCUri -Credential $TCCredential -Verbose:$Verbose
        }
		$TCOutput = $TCResponse | out-string
		Write-Verbose $TCOutput
		Return $TCResponse
	}
	catch {
		Write-Host "$_" 
		Throw "[ERROR] Invoke-TeamCityRESTAPI: $_"
		exit 1
	}
}