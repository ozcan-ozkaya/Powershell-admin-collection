<# Notes:

Goal - Prepare the local machine by installing needed PowerShell Gallery modules.
This script must be run before buildDomainController.

Disclaimer - This example code is provided without copyright and AS IS.  It is free for you to use and modify.

#>

Get-PackageSource -Name PSGallery | Set-PackageSource -Trusted -Force -ForceBootstrap

Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

Install-Module xActiveDirectory -Force
Install-Module xComputerManagement -Force
Install-Module xNetworking -Force
Install-Module xDnsServer -Force

Write-Host "You may now execute '.\buildDomainController.ps1'"