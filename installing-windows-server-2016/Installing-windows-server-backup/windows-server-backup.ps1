# Notes: 
# Below commands are an example for installing Windows server backup and create a backup of the IIS Server configuration

Get-WindowsFeature *backup*

Install-WindowsFeature windows-server-backup

# Backing up IIS Configuration Files @ C:\windows\system32
Backup-WebConfiguration -Name IISBackup

# Now you backup C:\inetpub\wwwroot + config files