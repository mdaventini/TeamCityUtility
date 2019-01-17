# TeamCityUtility
Utilities for TeamCity

This PowerShell module provides a series of cmdlets for interacting with [TeamCity](https://confluence.jetbrains.com/display/TCD18/Extending+TeamCity).

**IMPORTANT:** This was build and tested with TeamCity 2018.2

## Version 1

Manage parameteres: performed by wrapping `Invoke-RestMethod` for the [API](https://confluence.jetbrains.com/display/TCD18/REST+API) calls.

Back End:

* The module structure uses individual files for each function.

## Requirements

Requires PowerShell 3.0 or above as this is when `Invoke-RestMethod` was introduced.

## Cmdlets

* Set-TeamCityParam