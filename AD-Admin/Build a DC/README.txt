DISCLAIMER - This example code is provided without copyright and AS IS.  It is free for you to use and modify.

************************************************
windows-server-2016-manage-maintain-ad-domain-services-m2
************************************************

***** -- Create and configure Managed Service Accounts

Import-Module ActiveDirectory
New-ADServiceAccount -Name TestAccount -RestrictToSingleComputer -Enabled $True
Add-ADComputerServiceAccount -Identity mydesktop -ServiceAccount TestAccount

Install-ADServiceAccount -Identity TestAccount

***** -- Create and configure Group Managed Service Accounts

Add-KDSRootKey –EffectiveTime ((get-date).addhours(-10))

New-ADServiceAccount -name TestgMSA -DNSHostName testgmsa.company.pri -PrincipalsAllowedToRetrieveManagedPassword "Domain Computers"

Add-ADComputerServiceAccount -Identity mydesktop -ServiceAccount TestgMSA

Install-ADServiceAccount -Identity TestgMSA
Test-ADServiceAccount -Identity TestgMSA

New-Service -Name "TestService" -BinaryPathName "C:\WINDOWS\System32\svchost.exe -k netsvcs"

************************************************
windows-server-2016-manage-maintain-ad-domain-services-m3
************************************************

***** -- Back up Active Directory and SYSVOL

enter-pssession den-dc1
gcm -module windowsserverbackup
$policy = New-WBPolicy
$policy
AddWBSystemState -Policy $policy
$policy
Get-WBVolume -AllVolumes
Get-WBVolume -AllVolumes | where mountpath -eq "C:"
$volume = Get-WBVolume -AllVolumes | where mountpath -eq "C:"
Add-WBVolume -policy $policy -volume $volume
Get-WBDisk
Get-Disk
Set-Disk -Number 1 -IsOffline $false
Initialize-Disk -Number 1 -PartitionStyle GPT
New-Partition -DiskNumber 1 -UseMaximumSize -AssignDriveLetter
Format-Volume -DriveLetter E -FileSystem NTFS
$backupvolume = Get-WBVolume -AllVolumes | where mountpath -eq "E:"
$backuptarget = New-WBBackupTarget -volume $backupvolume
Add-WBBackupTarget -Policy $policy -Target $backuptarget
Set-WBSchedule -policy $policy -schedule 03:00
Set-WBPolicy -policy $policy
Start-WBBackup -policy $policy

***** -- Perform Active Directory restore

bcdedit /set safeboot dsrepair
restart-computer

Get-WBBackupSet
Get-WBBackupSet | where -versionid -eq WHATEVER
$backup = Get-WBBackupSet | where -versionid -eq WHATEVER
Start-WBSystemStateRecovery -backupset $backup -force -restartcomputer
Start-WBSystemStateRecovery -backupset $backup -authoritativesysvolrecovery -force
stop-service ntds
ntdsutil
activate instance ntds
authoritative restore
restore object "cn=Dan Jones,cn=users,dc=company,dc=pri"
restore subtree "cn=users,dc=company,dc=pri"

bcdedit /deletevalue safeboot

***** -- Perform object- and container-level recovery

Enable-ADOptionalFeature -Identity 'CN=Recycle Bin Feature,CN=Optional Features,CN=Directory Service,CN=Windows NT,CN=Services,CN=Configuration,DC=company,DC=pri' -Scope ForestOrConfigurationSet -Target 'company.pri'

Get-ADObject -Filter {displayName -eq "Dan Jones"} -IncludeDeletedObjects | Restore-ADObject

***** -- Configure Active Directory snapshots

ntdsutil
activate instance ntds
snapshot
create

list all
mount <GUID>
quit
quit
dsamain -dbpath c:\$snap_<datetime>_volumec$\ntds\ntds.dit -ldapport 50000

ADUC | Root node | Change Domain Controller
DEN-DC1:50000

ntdsutil
activate instance ntds
snapshot
unmount <GUID>
quit
quit

***** -- Perform offline defragmentation of an Active Directory database

stop-service "Active Directory Domain Services" -force
ntdsutil
activate instance ntds
files
compact to C:\
integrity
quit
quit
copy c:\ntds.dit c:\windows\ntds\ntds.dit
erase c:\windows\ntds\*.log
start-service "Active Directory Domain Services"

***** -- Clean up metadata

ntdsutil
metadata cleanup
connections
connect to server den-dc1
quit
select operation target
list domains
select domain X
list sites
select site Y
list servers
select server Z
quit
remove selected server
yes
quit

***** -- Monitor and manage replication

repadmin /showrepl
repadmin /showrepl PHX-DC1
repadmin /showconn PHX-DC1
repadmin /showobjmeta DEN-DC1 "CN=gshields,CN=users,DC=company,DC=pri"
repadmin /kcc
repadmin /kcc PHX-DC1
repadmin /replsum
repadmin /replicate DEN-DC1 DEN-DC2 "dc=company,dc=pri"
repadmin /syncall DEN-DC1 "dc=company,dc=pri" /d /e
dcdiag /s:den-dc1
get-adreplicationconnection -server den-dc1
get-adreplicationfailure -target phx-dc1

***** -- Configure Password Replication Policy for RODCs

repadmin /prp
repadmin /prp view den-rodc1 reveal
repadmin /prp add den-rodc1 allow cn=djones,cn=users,dc=company,dc=pri