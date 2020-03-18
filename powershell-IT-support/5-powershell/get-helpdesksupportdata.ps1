<#
.Synopsis
   This is a script to gather information for Help Desk support calls

.DESCRIPTION
   This is a basic script designed to gather user and computer information for helpdeks support calls.
   Information gathered includes:
   DNS Name & IP Address
   DNS Server
   Name of Operating System
   Amount of Memory in target computer
   Amount of free space on disk
   Last Reboot of System
   Last User Logon Date
   Group Membership of User
   Printers on System

.EXAMPLE
   Get-Support
   PS C:\scripts\M5> .\get-helpdesksupportdata.ps1

    cmdlet get-helpdesksupportdata.ps1 at command pipeline position 1
    Supply values for the following parameters:
    ComputerName: client02
    Username: mbender

    In this example, the script is simply run and the parameters are input as they are mandatory.
.EXAMPLE
   Get-SupportInfo.ps1 -ComputerName Client1 -Username usrmvb

   This example has mandatory parameters input when calling script.

.EXAMPLE
   Get-SupportInfo.ps1 -ComputerName Client1 -Username usrmvb | out-file c:\UserInfo.txt

   This example sends the output of the script to a text file.
#>

#Get-Helpdesksupport.ps1
#Michael Bender
#July 31, 2015
#August 14, 2015
#References

##Paramaters for Computername & UserName
Param (
[Parameter(Mandatory=$true)][string]$ComputerName,
[Parameter(Mandatory=$true)][string]$Username
)
#Variables

#IP Address
$DNSFQDN = Resolve-DnsName -Name $ComputerName | select Name,IPaddress

#DNS Server
$DNSServer= (Get-DNSClientServerAddress `
-cimsession (New-CimSession -computername $ComputerName) `
-InterfaceAlias "ethernet0" -AddressFamily IPv4).ServerAddresses

#OS Description -
$OS= (Get-CimInstance Win32_OperatingSystem -ComputerName $ComputerName).caption

#SystemMemory
$memory = ((((Get-CimInstance Win32_PhysicalMemory -ComputerName $Computername).Capacity|measure -Sum).Sum)/1gb)

#Last Reboot
$Reboot = (Get-CIMInstance -Class Win32_OperatingSystem –ComputerName $ComputerName).LastBootUpTime

#DiskSpace/Freespace
$drive =Invoke-Command -ComputerName client02 {get-psdrive| where Name -EQ "C"}
$Freespace =[Math]::Round(($drive.free)/1gb,2)

#UserInfo
$LastLogonUser = (Get-ADUser -Identity $Username -Property *).LastLogonDate
If ($LastLogonUser -eq $null) {
$LastLogonUser = "User has not logged onto network since account creation"
}

#Retrieve Group Membership of AD User Account
$ADGroupMembership = (get-aduser -Identity $Username -property *).memberof

#Printer
$Printers = Get-Printer -ComputerName $Computername | Select -Property Name,DriverName,Type | ft -AutoSize

#Write Output to Screen & Make available for pipeline commands

Write-Output "Username: $username" ; ""
Write-Output $UserAccounts;""
Write-Output "DNS Name & IP Address of Target:"
Write-Output $DNSFQDN;""
Write-Output "DNS Server of Target: $DNSServer";""
Write-Output "Last User Logon Attempt: $LastLogonUser";""
Write-output "Computername: $Computername";""
Write-Output "Total System RAM: $memory GB";""
Write-Output "Freespace on C:  $Freespace GB"
Write-Output "Printers Installed: "
Write-Output $Printers
Write-Output "Group Membership ( Displayed as Distinguished Name )"
Write-Output $ADGroupMembership
