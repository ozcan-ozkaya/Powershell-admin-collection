#IP Address
Resolve-DnsName Client02 | select Name,IPaddress

#DNS Server
(Get-DNSClientServerAddress `
-cimsession (New-CimSession -computername Client02) `
-InterfaceAlias "ethernet0" -AddressFamily IPv4).ServerAddresses

#OS Description
(Get-CimInstance Win32_OperatingSystem -ComputerName Client02).caption

#SystemMemory
((((Get-CimInstance Win32_PhysicalMemory -ComputerName Client02).Capacity|measure -Sum).Sum)/1gb)

#Last Reboot
(Get-CIMInstance -Class Win32_OperatingSystem –ComputerName Client02).LastBootUpTime
 
#DiskSpace/Freespace
(Invoke-Command -ComputerName client02 {get-psdrive| where Name -EQ "C"}).free

#UserInfo
(Get-ADUser -Identity mbender -Property *).LastLogonDate
 
#Retrieve Group Membership of AD User Account
(get-aduser -Identity mbender -property *).memberof
 
#User Accounts on System
(Get-CimInstance Win32_UserAccount -CimSession Client02 ).Caption
 
#Printer
Get-Printer -ComputerName Client02 | Select -Property Name,DriverName,Type | ft -AutoSize
 
