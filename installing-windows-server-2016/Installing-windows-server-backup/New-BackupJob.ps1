<#

Run a backup via PowerShell

Disclaimers

!!!!!!!!!!
This script is provided as an example and is not directly intended to be run as-is.
!!!!!!!!!!

This example code is provided without copyright and AS IS.  It is free for you to use and modify.
Note: These demos should not be run as a script. These are the commands that I use in the 
demonstrations and would need to be modified for your environment.

#>

$policy = New-WBPolicy 
 
$fileSpec = New-WBFileSpec -FileSpec C:\document2.txt
Add-WBFileSpec -Policy $policy -FileSpec $filespec 
 
Add-WBSystemState $policy 
Add-WBBareMetalRecovery $policy 
 
$backupLocation = New-WBBackupTarget -NetworkPath '\\dc\c$\backups' -Credential (Get-Credential)
Add-WBBackupTarget -Policy $policy -Target $backupLocation 
 
Set-WBVssBackupOptions -Policy $policy -VssCopyBackup 
 
Start-WBBackup -Policy $policy -Async