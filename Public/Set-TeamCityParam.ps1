function Set-TeamCityParam {
	param(
		[parameter(HelpMessage="Must be a valid TeamCity Url. Example -TCServerUrl 'http://TeamCity.yourdomain:8082'")][ValidateNotNullOrEmpty()][String[]]$TCServerUrl, 
		[parameter(HelpMessage="Valid UserName in TeamCity. Example -TCUser teamcityuser")][ValidateNotNullOrEmpty()][String[]]$TCUser,
		[parameter(HelpMessage="Password for valid UserName in TeamCity. ")][ValidateNotNullOrEmpty()][String[]]$TCSecret,
		[parameter(HelpMessage="Parameter Locator. Example -TCParamLocator 'projects/id:_Root'")][ValidateNotNullOrEmpty()][String[]]$TCParamLocator,
		[parameter(HelpMessage="Parameter Name. Example -TCParamName 'env.DefaultEnvironment'")][ValidateNotNullOrEmpty()][String[]]$TCParamName,
		[parameter(HelpMessage="Parameter rawValue. Example -TCParamRaw select display='hidden' description='Default environment to deploy to when using Octopus. This is also defined by Team tennants.' data_1='Dev' data_2='Test' data_3='Staging' data_4='Production'")][ValidateNotNullOrEmpty()][String[]]$TCParamRaw,
		[parameter(HelpMessage="Parameter Value. Example -TCParamValue Dev")][String[]][ValidateNotNull()]$TCParamValue
	)
	try {
		Write-Verbose "Creating CICredential for $TCUser"
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
		Write-Verbose "Getting Parameter $UriParameter"
		Write-Verbose "Will run Invoke-RestMethod -Method Get -Uri $UriParameter -Credential $CICredential -Verbose"
		$TCResponse = (Invoke-RestMethod -Method Get -Uri $UriParameter -Credential $CICredential)
        $ESValue = $TCResponse.property.value
        $ESRawValue = $TCResponse.property.type.rawValue
	}
	catch {
		Write-Host "$_" 
		Write-Verbose "$UriParameter does not exist ... creating"
        $JData = (@{value = "$TCParamValue"}) | ConvertTo-Json
		$TCResponse = ( Invoke-RestMethod -Method PUT -Uri $UriParameter -ContentType "application/json" -Credential $CICredential -Body $JData -Verbose )
        $ESValue = $TCResponse.property.value
     }
    Write-Verbose "Existing State is" $TCResponse.property.name $ESValue $ESRawValue
    try {
        if ( "$ESValue" -ne "$TCParamValue" ) {
    	    Write-Verbose "$UriParameter/value must be updated"
		    Write-Verbose "Will run Invoke-RestMethod -Method PUT -Uri $UriParameter/value -Credential $CICredential -Body $TCParamValue -Verbose"
		    $TCResponse = ( Invoke-RestMethod -Method PUT -Uri $UriParameter/value -Credential $CICredential -Body $TCParamValue -Verbose ) 
	    } else {
		    Write-Verbose "$UriParameter/value is up to date"
	    }
        if ( "$ESRawValue" -ne "$TCParamRaw" ) {
    	    Write-Verbose "$UriParameter/type/rawValue must be updated"
		    Write-Verbose "Will run Invoke-RestMethod -Method PUT -Uri $UriParameter/type/rawValue -Credential $CICredential -Body $TCParamRaw -Verbose"
		    $TCResponse = ( Invoke-RestMethod -Method PUT -Uri $UriParameter/type/rawValue -Credential $CICredential -Body $TCParamRaw -Verbose ) 
	    } else {
		    Write-Verbose "$UriParameter/type/rawValue is up to date"
	    }
	}
	catch {
        Write-Host "$_" 
		Write-Host "$UriParameter was not updated"
        exit 1
    }
}