<# Notes:

Goal - Create a domain controller and populate with OUs, Groups, and Users.

This script must be run after prepDomainController.ps1.

Disclaimer - This example code is provided without copyright and AS IS.  It is free for you to use and modify.

#>

<#
Specify the configuration to be applied to the server.  This section
defines which configurations you're interested in managing.
#>

configuration buildDomainController
{
    Import-DscResource -ModuleName xComputerManagement -ModuleVersion 3.2.0.0
    Import-DscResource -ModuleName xNetworking -ModuleVersion 5.4.0.0
    Import-DscResource -ModuleName xDnsServer -ModuleVersion 1.9.0.0
    Import-DscResource -ModuleName xActiveDirectory -ModuleVersion 2.16.0.0

    Node localhost
    {
        LocalConfigurationManager {
            ActionAfterReboot = "ContinueConfiguration"
            ConfigurationMode = "ApplyOnly"
            RebootNodeIfNeeded = $true
        }
  
        xIPAddress NewIPAddress {
            IPAddress = $node.IPAddressCIDR
            InterfaceAlias = $node.InterfaceAlias
            AddressFamily = "IPV4"
        }

        xDefaultGatewayAddress NewIPGateway {
            Address = $node.GatewayAddress
            InterfaceAlias = $node.InterfaceAlias
            AddressFamily = "IPV4"
            DependsOn = "[xIPAddress]NewIPAddress"
        }

        xDnsServerAddress PrimaryDNSClient {
            Address        = $node.DNSAddress
            InterfaceAlias = $node.InterfaceAlias
            AddressFamily = "IPV4"
            DependsOn = "[xDefaultGatewayAddress]NewIPGateway"
        }

        User Administrator {
            Ensure = "Present"
            UserName = "Administrator"
            Password = $Cred
            DependsOn = "[xDnsServerAddress]PrimaryDNSClient"
        }

        xComputer NewComputerName {
            Name = $node.ThisComputerName
            DependsOn = "[User]Administrator"
        }

        WindowsFeature DNSInstall {
            Ensure = "Present"
            Name = "DNS"
            DependsOn = "[xComputer]NewComputerName"
        }

        xDnsServerPrimaryZone addForwardZoneCompanyPri {
            Ensure = "Present"
            Name = "company.pri"
            DynamicUpdate = "NonsecureAndSecure"
            DependsOn = "[WindowsFeature]DNSInstall"
        }

        xDnsServerPrimaryZone addReverseADZone3Net {
            Ensure = "Present"
            Name = "3.168.192.in-addr.arpa"
            DynamicUpdate = "NonsecureAndSecure"
            DependsOn = "[WindowsFeature]DNSInstall"
        }

        xDnsServerPrimaryZone addReverseADZone4Net {
            Ensure = "Present"
            Name = "4.168.192.in-addr.arpa"
            DynamicUpdate = "NonsecureAndSecure"
            DependsOn = "[WindowsFeature]DNSInstall"
        }

        xDnsServerPrimaryZone addReverseADZone5Net {
            Ensure = "Present"
            Name = "5.168.192.in-addr.arpa"
            DynamicUpdate = "NonsecureAndSecure"
            DependsOn = "[WindowsFeature]DNSInstall"
        }

        WindowsFeature ADDSInstall {
            Ensure = "Present"
            Name = "AD-Domain-Services"
            DependsOn = "[xDnsServerPrimaryZone]addForwardZoneCompanyPri"
        }

        xADDomain FirstDC {
            DomainName = $node.DomainName
            DomainAdministratorCredential = $domainCred
            SafemodeAdministratorPassword = $domainCred
            DatabasePath = $node.DCDatabasePath
            LogPath = $node.DCLogPath
            SysvolPath = $node.SysvolPath 
            DependsOn = "[WindowsFeature]ADDSInstall"
        }

        xADUser myaccount {
            DomainName = $node.DomainName
            Path = "CN=Users,$($node.DomainDN)"
            UserName = "myaccount"
            GivenName = "My"
            Surname = "Account"
            DisplayName = "My Account"
            Enabled = $true
            Password = $Cred
            DomainAdministratorCredential = $Cred
            PasswordNeverExpires = $true
            DependsOn = "[xADDomain]FirstDC"
        }

        xADUser gshields {
            DomainName = $node.DomainName
            Path = "CN=Users,$($node.DomainDN)"
            UserName = "gshields"
            GivenName = "Greg"
            Surname = "Shields"
            DisplayName = "Greg Shields"
            Enabled = $true
            Password = $Cred
            DomainAdministratorCredential = $Cred
            PasswordNeverExpires = $true
            DependsOn = "[xADDomain]FirstDC"
        }

        xADUser djones {
            DomainName = $node.DomainName
            Path = "CN=Users,$($node.DomainDN)"
            UserName = "djones"
            GivenName = "Dan"
            Surname = "Jones"
            DisplayName = "Dan Jones"
            Enabled = $true
            Password = $Cred
            DomainAdministratorCredential = $Cred
            PasswordNeverExpires = $true
            DependsOn = "[xADDomain]FirstDC"
        }

        xADUser jhelmick {
            DomainName = $node.DomainName
            Path = "CN=Users,$($node.DomainDN)"
            UserName = "jhelmick"
            GivenName = "Jane"
            Surname = "Helmick"
            DisplayName = "Jane Helmick"
            Enabled = $true
            Password = $Cred
            DomainAdministratorCredential = $Cred
            PasswordNeverExpires = $true
            DependsOn = "[xADDomain]FirstDC"
        }

        xADGroup IT {
            GroupName = "IT"
            Path = "CN=Users,$($node.DomainDN)"
            Category = "Security"
            GroupScope = "Global"
            MembersToInclude = "gshields", "jhelmick", "myaccount"
            DependsOn = "[xADDomain]FirstDC"
        }

        xADGroup DomainAdmins {
            GroupName = "Domain Admins"
            Path = "CN=Users,$($node.DomainDN)"
            Category = "Security"
            GroupScope = "Global"
            MembersToInclude = "gshields", "myaccount"
            DependsOn = "[xADDomain]FirstDC"
        }

        xADGroup EnterpriseAdmins {
            GroupName = "Enterprise Admins"
            Path = "CN=Users,$($node.DomainDN)"
            Category = "Security"
            GroupScope = "Universal"
            MembersToInclude = "gshields", "myaccount"
            DependsOn = "[xADDomain]FirstDC"
        }

        xADGroup SchemaAdmins {
            GroupName = "Schema Admins"
            Path = "CN=Users,$($node.DomainDN)"
            Category = "Security"
            GroupScope = "Universal"
            MembersToInclude = "gshields", "myaccount"
            DependsOn = "[xADDomain]FirstDC"
        }
    }
}

<#
Specify values for the configurations you're interested in managing.
See in the configuration above how variables are used to reference values listed here.
#>
            
$ConfigData = @{
    AllNodes = @(
        @{
            Nodename = "localhost"
            ThisComputerName = "dc"
            IPAddressCIDR = "192.168.3.10/24"
            GatewayAddress = "192.168.3.2"
            DNSAddress = "192.168.3.10"
            InterfaceAlias = "Ethernet0"
            DomainName = "company.pri"
            DomainDN = "DC=Company,DC=Pri"
            DCDatabasePath = "C:\NTDS"
            DCLogPath = "C:\NTDS"
            SysvolPath = "C:\Sysvol"
            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser = $true
        }
    )
}

<#
Lastly, prompt for the necessary username and password combinations, then
compile the configuration, and then instruct the server to execute that
configuration against the settings on this local server.
#>

$domainCred = Get-Credential -UserName company\Administrator -Message "Please enter a new password for Domain Administrator."
$Cred = Get-Credential -UserName Administrator -Message "Please enter a new password for Local Administrator and other accounts."

BuildDomainController -ConfigurationData $ConfigData

Set-DSCLocalConfigurationManager -Path .\buildDomainController –Verbose
Start-DscConfiguration -Wait -Force -Path .\buildDomainController -Verbose