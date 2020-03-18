#requires -version 3.0

#demo snapins and modules

#region PSSnapins
get-command -Noun PSSnapin

#show currently installed snapins
Get-PSSnapin

#-module is an alias for -pssnapin
get-command -Module *core | more

#list all available
Get-PSSnapin -Registered

#adding a 3rd party snapin
Add-PSSnapin Quest*
gcm -mod quest* | more

#now I have all those commands
help get-qaduser
get-qaduser jfrost

Remove-PSSnapin quest*
#now the tools are gone
get-qaduser jfrost

#read more
help about_PSSnapins 
cls

#endregion

#region Modules

get-command -noun Module

#what is loaded?
Get-Module

#PowerShell searches these paths
$env:PSModulePath

#list system modules
dir $pshome\modules

#what is available?
Get-Module -ListAvailable

#getting commands
gcm -mod psscheduledjob

Import-Module PSWorkflow
gmo
gcm -mod PSworkflow
#remove it
remove-module PSWorkflow
gmo

#autoload
help Get-SmbShare
gmo

#read more
help about_modules

cls
#endregion
