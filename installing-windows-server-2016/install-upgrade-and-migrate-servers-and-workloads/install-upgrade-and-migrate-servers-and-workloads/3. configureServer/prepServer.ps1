<# Notes:

Goal - Prepare the server by connecting to the gallery,
installing the package provider, and installing the modules
required by the configuration.  Note that the modules to be installed
are versioned to protect against future breaking changes.

This script must be run before configureServer.ps1.

Disclaimer - This example code is provided without copyright and AS IS.  
It is free for you to use and modify.

#>

Get-PackageSource -Name PSGallery | Set-PackageSource -Trusted -Force -ForceBootstrap

Install-PackageProvider -Name NuGet -Force

Install-Module xComputerManagement -RequiredVersion 3.2.0.0 -Force
Install-Module xNetworking -RequiredVersion 5.4.0.0 -Force

Write-Host "You may now execute '.\configureServer.ps1'"