# TeamCityUtility
This PowerShell module provides a series of cmdlets for interacting with [TeamCity](https://confluence.jetbrains.com/display/TCD18/Extending+TeamCity).

## IMPORTANT
This was build and tested with TeamCity 2018.2.

Requires PowerShell 3.0 or above as this is when `Invoke-RestMethod` was introduced.

## NOTES
The module structure uses individual files for each function.

## Cmdlets

* Set-TCCredential (since TeamCityUtility 2.)
* Get-TeamCityActiveBranches (since TeamCityUtility 1.1)
* Get-TeamCityParam (since TeamCityUtility 1.1)
* Get-TeamCityProjects (since TeamCityUtility 1.1)
* Get-TeamCityProperty (since TeamCityUtility 1.1)
* Set-TeamCityBuildComment (since TeamCityUtility 1.1)
* Set-TeamCityParam (since TeamCityUtility 1.1)
* Get-TeamCityChanges (since TeamCityUtility 1.1)
* Get-TeamCityBuildsByRevision (since TeamCityUtility 1.1)

## Version 2.

Requires to run Set-TCCredential to create $TCCredential "System.Management.Automation.PSCredential" Global variable.

## Version 1.

Manage TeamCity configurations: performed by wrapping `Invoke-RestMethod` for the [TeamCity REST API](https://confluence.jetbrains.com/display/TCD18/REST+API) calls.
